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
end
