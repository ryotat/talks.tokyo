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
      within "td.centre" do
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
