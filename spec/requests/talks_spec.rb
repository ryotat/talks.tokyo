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
