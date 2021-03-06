# -*- coding: utf-8 -*-
require 'spec_helper'

describe "index" do
  describe "dates" do
    let(:user) { FactoryGirl.create(:albert) }
    let(:talk) { FactoryGirl.create(:talk) }
    before do
      sign_in user
    end
    context "two talks" do
      subject { page }
      let(:talk2) { FactoryGirl.create(:talk, :start_time => talk.start_time) }
      before do
        visit talk_path(talk2)
        visit date_index_path(:year => talk.start_time.year,
                              :month => talk.start_time.month,
                              :day => talk.start_time.day)
      end
      it { should have_content(talk.title) }
      it { should have_content(talk2.title) }
      it "should not show deleted talks", :js => true do
        visit talk_path(talk)
        click_link "Delete this talk"
        page.should have_content "Are you sure?"
        click_link "Cancel"
        visit talk_path(talk)
        page.should have_content("This talk has been canceled/deleted")
        visit date_index_path(:year => talk.start_time.year,
                              :month => talk.start_time.month,
                              :day => talk.start_time.day)
        page.should have_no_content(talk.title)
        page.should have_content(talk2.title)
      end
    end
  end
end
