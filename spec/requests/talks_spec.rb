# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Talks" do
  subject { page }
  describe "new",  :js => true do
    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, :name => "Name of a list", :organizer => user) }
    context "for an organizer" do
      before do
        sign_in user
        visit list_path(list)
        dropdown_new_talk(list)
      end
      it { should_not show_403}
      it { should_not show_404}
      it { should have_content("Title") }
      specify { find(:xpath, "//input[@id='talk_date_string']").value.should == Time.zone.now.strftime("%Y/%m/%d") }
      it { should have_selector("input#talk_title") }
      context "Edit" do
        context "Title" do
          before do
            fill_in "talk_title", :with => "Name of a new talk"
            click_button "Save"
          end
          it { should have_content "Talk ‘Name of a new talk’ has been created." }
        end
        context "Special characters" do
          before do
            fill_in "talk_title", :with => "Statistical learning when p>>N"
            click_button "Save"
          end
          it { should have_content "Statistical learning when p>>N" }
        end

      end
    end
    context "for a non-organizer", :user => :visitor do
      before do
        visit new_talk_path("list_id" => list.id)
      end
      it { should show_403 }
      it { should_not have_content("title") }
      it { should_not have_selector("input#talk_title") }
    end
    context "exists future talk" do
      let(:future_talk) { FactoryGirl.create(:talk, :start_time => Time.zone.now + 10.days, :end_time => Time.zone.now + 10.days + 2.hours, :series => list) }
      before do
        sign_in user
        visit talk_path(future_talk)
        dropdown_new_talk(list)
      end
      it { find(:xpath, "//input[@id='talk_date_string']").value.should == future_talk.start_time.strftime("%Y/%m/%d") }
    end
  end
  describe "edit" do
    let(:talk) { FactoryGirl.create(:talk) }
    it "should not allow a stranger to edit a talk"  do
      user = FactoryGirl.create(:user)
      sign_in user
      visit edit_talk_path(talk)
      page.should show_403
    end
    describe "valid edit" do
      before do
        host! 'localhost:3000'
        sign_in talk.series.users[0]
        visit edit_talk_path(talk)
      end        
      it "should open SmartForm", :js => true do
        page.should have_selector('div#smartform', visible: false)
        click_link "Just copy & paste into SmartForm"
        page.should have_selector('div#smartform', visible: true)
      end
      it "should have necessary fields" do
        page.should have_selector('input#talk_series_id')
        page.should have_selector('input#talk_title')
        page.should have_selector('input#talk_name_of_speaker')
        page.should have_selector('textarea#talk_abstract')
        page.should have_selector('input#talk_date_string')
        page.should have_selector('input#talk_start_time_string')
        page.should have_selector('input#talk_end_time_string')
        page.should have_selector('input#talk_venue_name')
        page.should have_selector('select#talk_language')
        page.should have_selector('input#talk_send_speaker_email')
        page.should have_selector('input#talk_speaker_email')
        page.should have_selector('input#talk_image')
        page.should have_no_selector('input#talk_special_message')
        page.should have_selector('input#talk_ex_directory')
        page.should have_xpath("//input[@id='talk_organiser_email'][@type='hidden']")
      end
      
      it "should toggle talk_speaker_email", :js => true do
        page.should have_selector('input#talk_speaker_email', visible: false)
        check "talk_send_speaker_email"
        page.should have_selector('input#talk_speaker_email', visible: true)
        uncheck "talk_send_speaker_email"
        page.should have_selector('input#talk_speaker_email', visible: false)
      end
      
      it "should suggest a venue", :js => true do
        talk2=FactoryGirl.create(:talk, :series => talk.series, :venue => FactoryGirl.create(:venue, :name => 'Another Venue'))
        visit talk_path(talk2)
        visit edit_talk_path(talk)
        page.find('#talk_venue_name').trigger(:focus)
        page.should have_content "Please enter the full name of the venue"
        fill_in "talk_venue_name", :with => "Another V"
        click_link "Another Venue"
        find(:xpath, "//input[@id='talk_venue_name']").value.should == "Another Venue"
      end

      describe "should suggest a speaker", :js => true do
        let(:user2) {FactoryGirl.create(:user, :name => "Mr. Blabla") }
        before do
          visit user_path(:action => "show", :id => user2.id)
          visit edit_talk_path(talk)
        end
        it "from name" do
          page.find("#talk_name_of_speaker").trigger(:focus)
          page.should have_content "Please write the name and affiliation of the speaker"
          fill_in "talk_name_of_speaker", :with => "Blabla"
          click_link "Mr. Blabla"
          find(:xpath,"//input[@id='talk_name_of_speaker']").value.should include(user2.name)
        end
        it "from email" do
          check "talk_send_speaker_email"
          page.find("#talk_speaker_email").trigger(:focus)
          page.should have_content "Please enter the speaker's e-mail address."
          fill_in "talk_speaker_email", :with => user2.email
          sleep(1)
          click_link "Mr. Blabla"
          find(:xpath,"//input[@id='talk_name_of_speaker']").value.should include(user2.name)
        end
     end

      describe "speaker_invite", :js => true do
        let(:user) { FactoryGirl.create(:user) }
        let(:password) { user.password }
        before do
          fill_in "talk_title", :with => "The title"
          fill_in "talk_name_of_speaker", :with => user.name
          check "talk_send_speaker_email"
          fill_in "talk_speaker_email", :with => user.email
          click_button "Save"
        end        
        it { should have_content "Talk ‘The title’ has been saved"  }
        it "should send email speaker" do
          sleep(1)
          last_email.to.should include(user.email)
          last_email.body.should include("The title")
          last_email.body.should include(talk_url(:action => "edit", :id => talk.id))
          last_email.body.should include(login_url(:action => "send_password", :email => user.email))
        end
        it "should not mess with exisiting user" do
          sign_out
          sign_in user, password
          page.should have_content("You have been logged in.")
        end
      end

      describe "don't invite speaker when send_speaker_email is unchecked", :js => true do
        let(:user) { FactoryGirl.create(:user) }
        before do
          fill_in "talk_title", :with => "The title"
          fill_in "talk_name_of_speaker", :with => user.name
          check "talk_send_speaker_email"
          fill_in "talk_speaker_email", :with => user.email
          uncheck "talk_send_speaker_email"
          click_button "Save"
          sleep(1)
        end
        it { should have_content "Talk ‘The title’ has been saved"  }
        it "should not send email" do
          if last_email
            last_email.to.should_not include(user.email)
          else
            last_email.should be_nil
          end
        end
      end
    end
    describe "script attack", :js => true do
      before do
        sign_in talk.series.users[0]
        visit edit_talk_path(talk)
        fill_in "talk_abstract", :with => bad_script
        fill_in "talk_title", :with => bad_script
        fill_in "talk_venue_name", :with => bad_script
        click_button "Save"
      end
      it { should have_content bad_script }
      it { should have_no_xpath("//b", :text => "I got you") }
    end
  end
  describe "show" do
    let(:talk) { FactoryGirl.create(:talk) }
    before do
      visit talk_path(talk)
    end
    it { should have_link_to talk_associations_path(talk)  }
    it { should have_link_to talk_path(talk, :format => 'ics') }
    # it { should have_no_xpath "//a[@title='%s'][@data-remote='true']"% new_tickle_path('tickle[about_id]' => talk.id, 'tickle[about_type]' => 'Talk') }
    it { should have_link_to user_path(:id => talk.organiser) }
    context "listed in personal list", :js => true do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
        visit talk_path(talk)
        within('div.talk') { click_link "Add to your list" }
      end
      it { should have_content "Added ‘#{talk.title}’ to your personal list" }
      context "then visit talk" do
        before do
          visit talk_path(talk)
        end
        specify do
          within('div.talk') do
            page.should_not have_xpath ".//a[@href='#{list_path(user.personal_list)}']" 
          end
        end
      end
    end

    describe "add/remove from lists" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
        visit talk_path(talk)
      end
      it { should have_link_to talk_associations_path(talk) }
    end
#     describe "tell a friend", :js => true do
#       let(:user) { FactoryGirl.create(:user) }
#       before do
#         sign_in user
#       end
#       it "should send an email" do
#         visit talk_path(talk)
#         click_link "Tell a friend"
#         wait_until { page.has_content? "Tell a friend about this talk" }
#         fill_in "tickle_recipient_email", :with => "a@a.jp"
#         fill_in "tickle_subject", :with => "Test title"
#         click_button "Send e-mail"
#         wait_until { page.has_content? "e-mail sent to" }
#         last_email.to.should include "a@a.jp"
#         last_email.subject.should == "Test title"
#         last_email.body.should include "ID: 1"
#       end
#     end
    context "for an organizer " do
      before do
        sign_in talk.series.users[0]
        visit talk_path(talk)
      end
      it { should have_link_to talk_path(talk, :format => :txt) }
      it { should have_link_to delete_talk_path(talk) }
    end
  end
  describe "delete", :js => true do
    let(:talk) { FactoryGirl.create(:talk) }
    before do
      visit talk_path(talk)
    end
    context "for an organizer" do
      before do
        sign_in talk.series.users[0]
        visit talk_path(talk)
        click_link 'Delete this talk'
      end
      it { should have_content "Are you sure?" }
      it { should have_xpath "//a[@href='#{talk_path(talk)}'][@data-method='delete']" }
      it { should have_link_to cancel_talk_path(talk) }
      context "click delete" do
        before do
          within('div#talks-modal') { click_link 'Delete' }
        end
        it { should have_content "Talk ‘#{talk.name}’ has been deleted." }
        context "then visit talk" do
          before { visit talk_path(talk) }
          it { should show_404 }
        end
      end
      context "click cancel" do
        before do
          within('div#talks-modal') { click_link 'Cancel' }
        end
        it { should have_content "Talk ‘#{talk.name}’ has been canceled." }
        context "then visit talk" do
          before { visit talk_path(talk) }
          it { should have_content "This talk has been canceled/deleted" }
        end
      end
    end
    context "for a non-organizer", :user => :visitor do
      before do
        visit talk_path(talk)
      end
      it { should_not have_link_to delete_talk_path(talk) }
      context "try to delete" do
        before { visit delete_talk_path(talk) }
        it { should show_403 }
      end
    end
  end
  describe "special_message", :js => true do
    let(:talk) { FactoryGirl.create(:talk) }
    context "for an organizer" do
      before do
        sign_in talk.series.users[0]
        visit talk_path(talk)
	click_link "Add a special message"
      end
      it { should have_content "Anything you write here will be displayed prominently" }
      context "add message" do
        before do
          fill_in 'talk_special_message', :with => "This is a test."
          click_button 'Save'
        end
        it { should have_content "Successfully updated the special message." }
        it { should have_content "This is a test." }
        context "for a non-organizer", :user => :visitor do
          before do
            visit talk_path(talk)
          end
          it { should have_no_link "Edit", href: edit_talks_special_message_path(talk) }
        end
        context "edit message" do
          before do
            visit talk_path(talk)
            page.find('p#special-msg').trigger(:mouseover)
            click_link 'Edit'
          end
          it { should have_content "Anything you write here will be displayed prominently" }
          context "edit" do
            before do
              fill_in 'talk_special_message', :with => "Another test."
              click_button 'Save'
            end
            it { should have_content "Successfully updated the special message." }
            it { should have_no_content "This is a test." }
            it { should have_content "Another test." }
          end
        end
      end
    end
    context "keyword-organiser" do
      let(:talk1) { FactoryGirl.create(:talk, :special_message => "Please contact the organiser.") }
      before do
        visit talk_path(talk1)
      end
      specify { within("p.urgent") { should have_link_to user_path(talk1.organiser) } }
      context "in series" do
        before do
          visit list_path(talk1.series)
        end
        specify { within("p.urgent") { should have_link_to user_path(talk1.organiser) } }
      end
    end
    context "keyword-series" do
      let(:talk1) { FactoryGirl.create(:talk, :special_message => "It is part of series.") }
      before do
        visit talk_path(talk1)
      end
      specify { within("p.urgent") { should have_link_to list_path(talk1.series) } }
      context "in series" do
        before do
          visit list_path(talk1.series)
        end
        specify { within("p.urgent") { should have_link_to list_path(talk1.series) } }
      end
    end
  end
  describe "escape", :js => true do
    let(:venue) { FactoryGirl.create(:venue, :name => bad_script) }
    let(:talk) { FactoryGirl.create(:talk, :title => bad_script, :venue => venue, :abstract => bad_script, :special_message => bad_script) }
    before do
      visit talk_path(talk)
    end
    it { should  have_no_xpath("//b", :text => "I got you") }
  end
  describe "text" do
    let(:talk) { FactoryGirl.create(:talk, :start_time => Time.zone.local(2012,4,2,10), :end_time => Time.zone.local(2012,4,2,11,30)) }
    context "should show Japanese for locale=ja" do
      before do
        visit talk_path(talk, :format=> :txt, :locale => :ja)
      end
      it { should have_content("日時: 2012/4/2 (月), 10:00-11:30") }
      it { should have_content("場所: #{talk.venue.name}") }
      it { should have_content("講演者: #{talk.name_of_speaker}") }
      it { should have_content("タイトル: #{talk.title}") }
    end
    context "should show English for locale=en" do
      before do
        visit talk_path(talk, :format=> :txt, :locale => :en)
      end
      it { should have_content("Date & Time: Monday 2nd April 2012, 10:00-11:30") }
      it { should have_content("Venue: #{talk.venue.name}") }
      it { should have_content("Speaker: #{talk.name_of_speaker}") }
      it { should have_content("Title: #{talk.title}") }
    end
  end
end
