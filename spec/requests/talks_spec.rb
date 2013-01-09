# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Talks" do
  describe "new" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
    end
    it "should allow an organizer to create a new talk" do
      create_list user, "A list"
      click_link "Add a new talk"
      within "ul#lists" do
        click_link "A list"
      end
      page.should_not show_403
      page.should_not show_404
      page.should have_content("Title")
      page.should have_selector("input#talk_title")
    end
    it "should not render edit for a new talk when the user is not an organizer" do
      list = FactoryGirl.create(:list)
      visit talk_path(:action => "new", "list_id" => list.id)
      page.should_not have_content("title")
      page.should_not have_selector("input#talk_title")
    end

  end
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    let(:talk) { FactoryGirl.create(:talk) }
    let(:password) { user.password }
    it "should not allow a stranger to edit a talk"  do
      user = FactoryGirl.create(:user)
      sign_in user
      visit talk_path(:action => "edit", :id => talk.id)
      page.should show_403
    end
    describe "speaker_invite" do
      before do
        host! 'localhost:3000'
        sign_in talk.series.users[0]
        visit talk_path(:action => "edit", :id => talk.id)
        fill_in "talk_title", :with => "The title"
        fill_in "talk_name_of_speaker", :with => user.name
        fill_in "talk_speaker_email", :with => user.email
        check "talk_send_speaker_email"
        click_button "Save"
      end        
      it "should send email speaker" do
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
      page.should_not have_xpath "//a[@href='%s'][@data-remote='true']"% tell_a_friend_path('tickle[about_id]' => talk.id, 'tickle[about_type]' => 'Talk')
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
      end
    end
  end

  describe "edit" do
    let(:talk) { FactoryGirl.create(:talk) }
    let(:user) { talk.series.users[0] }
    before do
      sign_in user
      visit talk_path(:action => 'edit', :id => talk.id)
    end
    it "should open SmartForm", :js => true do
      page.should have_selector('div#smartform', visible: false)
      click_link "Just copy & paste into SmartForm"
      page.should have_selector('div#smartform', visible: true)
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
