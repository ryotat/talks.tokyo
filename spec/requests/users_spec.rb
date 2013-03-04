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
    it "should not show ex_directory talks" do
      talk = FactoryGirl.create(:talk, :name_of_speaker => user.name, :speaker_email => user.email)
      visit talk_path(talk)
      sign_in user
      visit user_path(user)
      page.should have_content(talk.title)
      visit talk_path(talk)
      click_link 'Delete this talk'
      click_button 'Delete Talk'
      visit user_path(user)
      page.should have_no_content(talk.title)
    end
  end

  describe "escape" do
    let(:user) { FactoryGirl.create(:user, :name => bad_script, :affiliation => bad_script) }
    it "should properly escape" do
      visit user_path(:action => 'show', :id => user.id)
      page.should  have_no_xpath("//b", :text => "I got you")
    end
  end
end
