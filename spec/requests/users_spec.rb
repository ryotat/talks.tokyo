# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Users" do
  let(:user) { FactoryGirl.create(:user) }
  describe "show" do
    it "should not show the full email" do
      bob = FactoryGirl.create(:bob)
      sign_in bob
      visit user_path(:id => user.id)
      page.should_not have_xpath("//a[@href = 'mailto:#{user.email}']")
    end
  end
end
