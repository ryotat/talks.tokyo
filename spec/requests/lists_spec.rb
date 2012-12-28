# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Lists" do
  describe "Generate a link to post a talk" do
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, :users => [user]) }
    before do
      sign_in user
    end
    it "should show a link" do
      list_id = list.id
      old_password = list.talk_post_password
      visit list_details_path(:action => 'edit', :id => list_id)
      click_link "Show a link"
      list = List.find(list_id)
      list.talk_post_password.should == old_password
      page.should have_content new_posted_talk_url_for(list)
      page.should have_content "Generate a new one"
    end

    it "should generate a link" do
      list_id = list.id
      old_password = list.talk_post_password
      visit list_details_path(:action => 'edit', :id => list_id)
      click_link "Show a link"
      click_link "Generate a new one"
      list = List.find(list_id)
      list.talk_post_password.should_not == old_password
      page.should have_content new_posted_talk_url_for(list)
    end
  end
  describe "choose" do
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, :users => [user]) }
    before do
      sign_in user
    end
    it "should not say talks.cam" do
      visit list_details_path(:action => "choose")
      page.should_not have_content "talks.cam"
    end
  end

  describe "new" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
    end
    it "should not say talks.cam" do
      visit list_details_path(:action => "new")
      page.should_not have_content "talks.cam"
    end
  end

  describe "show" do
    let(:list) { FactoryGirl.create(:list) }
    it "should show the year for a talk that is more than half a year ago" do
      talk = FactoryGirl.create(:talk, :start_time => 190.days.ago, :series => list)
      visit list_path(:id => list.id)
      within('div.simpletalk') do
        page.should have_content(talk.start_time.year)
      end
    end
    it "should show the year for a talk that is more than half a year away" do
      talk = FactoryGirl.create(:talk, :start_time => 190.days.from_now, :series => list)
      visit list_path(:id => list.id)
      within('div.simpletalk') do
        page.should have_content(talk.start_time.year)
      end
    end
  end
end
