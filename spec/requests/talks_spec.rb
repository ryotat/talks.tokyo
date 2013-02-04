# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Talks" do
  describe "new",  :js => true do
    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, :name => "Name of a list", :organizer => user) }
    before do
      sign_in user
      visit list_path(:id => list.id)
      click_link "new talk"
      wait_until { page.has_content? list.name }
      click_link list.name
    end
    it "should allow an organizer to create a new talk" do
      page.should_not show_403
      page.should_not show_404
      page.should have_content("Title")
      page.should have_selector("input#talk_title")
      fill_in "talk_title", :with => "Name of a new talk"
      click_button "Save"
      page.should have_content "Talk ‘Name of a new talk’ has been saved."
    end
    it "should not render edit for a new talk when the user is not an organizer" do
      sign_out
      sign_in user2
      visit talk_path(:action => "new", "list_id" => list.id)
      page.should show_403
      page.should_not have_content("title")
      page.should_not have_selector("input#talk_title")
    end
    it "should allow escaped characters", :js => true do
      fill_in "talk_title", :with => "Statistical learning when p>>N"
      click_button "Save"
      page.should have_content "Statistical learning when p>>N"
    end
  end
  describe "edit" do
    let(:talk) { FactoryGirl.create(:talk) }
    it "should not allow a stranger to edit a talk"  do
      user = FactoryGirl.create(:user)
      sign_in user
      visit talk_path(:action => "edit", :id => talk.id)
      page.should show_403
    end
    describe "valid edit" do
      before do
        host! 'localhost:3000'
        sign_in talk.series.users[0]
        visit talk_path(:action => "edit", :id => talk.id)
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
        page.should have_selector('input#talk_language_name')
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
        visit talk_path(talk2.id)
        visit talk_path(:action => "edit", :id => talk.id)
        fill_in "talk_venue_name", :with => "A"
        wait_until { page.has_content? "Please enter the full name of the venue" }
        fill_in "talk_venue_name", :with => "Another V"
        click_link "Another Venue"
        find(:xpath, "//input[@id='talk_venue_name']").value.should == "Another Venue"
      end

      describe "should suggest a speaker", :js => true do
        let(:user2) {FactoryGirl.create(:user, :name => "Mr. Blabla") }
        before do
          visit user_path(:action => "show", :id => user2.id)
          visit talk_path(:action => "edit", :id => talk.id)
        end
        it "from name" do
          fill_in "talk_name_of_speaker", :with => "B"
          wait_until { page.has_content? "Please write the name and affiliation of the speaker" }
          fill_in "talk_name_of_speaker", :with => "Blabla"
          click_link "Mr. Blabla"
          find(:xpath,"//input[@id='talk_name_of_speaker']").value.should include(user2.name)
        end
        it "from email" do
          check "talk_send_speaker_email"
          fill_in "talk_speaker_email", :with => "bla"
          wait_until { page.has_content? "Please enter the speaker's e-mail address." }
          fill_in "talk_speaker_email", :with => user2.email
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
        it "should send email speaker" do
          wait_until { page.has_content? "Talk ‘The title’ has been saved" }
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
        it "should not send email" do
          fill_in "talk_title", :with => "The title"
          fill_in "talk_name_of_speaker", :with => user.name
          check "talk_send_speaker_email"
          fill_in "talk_speaker_email", :with => user.email
          uncheck "talk_send_speaker_email"
          click_button "Save"
          wait_until { page.has_content? "Talk ‘The title’ has been saved" }
          if last_email
            last_email.to.should_not include(user.email)
          end
        end
      end
    end
  end
  describe "index" do
    let(:talk) { FactoryGirl.create(:talk) }
    before do
      visit talk_path(:id => talk.id)
    end
    it "should have a button to add/remove to lists" do
      page.should have_link_to include_talk_path(:action => 'create', :id => talk.id, :child => talk.id)
    end
    it "should have a button to download vcal" do
      page.should have_link_to talk_path(:action => 'vcal', :id => talk.id)
    end
    it "should have a button to view as text" do
      page.should have_link_to talk_path(:action => 'index', :format => :txt, :id => talk.id)
    end
    it "should not have a button to email friends" do
      page.should_not have_xpath "//a[@data-original-title='%s'][@data-remote='true']"% tell_a_friend_path('tickle[about_id]' => talk.id, 'tickle[about_type]' => 'Talk')
    end
    it "should have a button to contact organizer" do
      page.should have_link_to user_path(:id => talk.organiser)
    end
    describe "tell a friend", :js => true do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
      end
      it "should send an email" do
        visit talk_path(:id => talk.id)
        find(:xpath, "//a[@data-original-title='Tell a friend']").click
        fill_in "tickle_recipient_email", :with => "a@a.jp"
        fill_in "tickle_subject", :with => "Test title"
        click_button "Send e-mail"
        wait_until { page.has_content? "e-mail sent to" }
        last_email.to.should include "a@a.jp"
        last_email.subject.should == "Test title"
        last_email.body.should include "ID: 1"
      end
    end
  end
  describe "escape", :js => true do
    let(:venue) { FactoryGirl.create(:venue, :name => bad_script) }
    let(:talk) { FactoryGirl.create(:talk, :title => bad_script, :venue => venue, :abstract => bad_script) }
    it "should properly escape" do
      visit talk_path(:id => talk.id)
      page.should  have_no_xpath("//b", :text => "I got you")
    end
  end
  describe "text" do
    let(:talk) { FactoryGirl.create(:talk) }
    it "should show Japanese for locale=ja" do
      visit talk_path(:action => "index", :id => talk.id, :format=> :txt, :locale => :ja)
      page.should have_content("日時")
      page.should have_content("場所")
    end
    it "should show English for locale=en" do
      visit talk_path(:action => "index", :id => talk.id, :format=> :txt, :locale => :en)
      page.should have_content("Date & Time")
      page.should have_content("Venue")
    end
  end
end
