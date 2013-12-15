# -*- coding: utf-8 -*-
require 'spec_helper'
require "rexml/document"


describe "Venues" do
  subject { page }
  let(:list) { FactoryGirl.create(:list) }
  before do
    sign_in list.users[0]
    5.times.map do |i|
      visit list_path(list)
      click_link "Add a new talk"
      fill_in :talk_venue_name, :with => "Venue #{i}"
      click_button "Save"
    end
    sign_out
  end
  describe "index" do
    context "not logged in" do
      before do
        visit venues_path
      end
      it { should have_content "You need to be logged in to carry this out." }
    end
    context "list manager" do
      before do
        sign_in list.users[0]
        visit venues_path
      end
      specify do
        list.talks.each do |t| 
          within('div.span12') { page.should have_content t.venue.name }
          within('ul.dropdown-menu') { page.should have_no_content t.venue.name }
        end
      end
    end
    context "administrator", :user => :admin do
      before do
        visit venues_path
      end
      specify do
        list.talks.each do |t| 
          within('div.span12') { page.should have_content t.venue.name }
          within('ul.dropdown-menu') { page.should have_no_content t.venue.name }
        end
      end
    end
  end
  context "create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:list2) { FactoryGirl.create(:list, :organizer => user) }
    before do
      sign_in user
      visit list_path(list2)
    end
    context "identical name" do
      before do
        click_link "Add a new talk"
        fill_in :talk_venue_name, :with => "Venue 1"
        click_button "Save"
      end
      it { should have_content "Venue 1" }
      context "click link" do
        before do
          click_link "Venue 1"
        end
        it { should have_css('div.simpletalk', :count => 2) }
      end
    end
    context "different name" do
      before do
        click_link "Add a new talk"
        fill_in :talk_venue_name, :with => "Another Venue 1"
        click_button "Save"
      end
      it { should have_content "Another Venue 1" }
      context "click link" do
        before do
          click_link "Another Venue 1"
        end
        it { should have_css('div.simpletalk', :count => 1) }
      end
    end
  end
end
