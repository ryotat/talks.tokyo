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
end
