# -*- coding: utf-8 -*-
require 'spec_helper'

describe "ListTalks" do
  let(:user) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list, :name => "A public list", :organizer => user) }
  let(:talk) { FactoryGirl.create(:talk, :ex_directory => true) }
  before do
    sign_in user
    visit list_path(list.id)
  end
  describe "create" do
    it "should not list a private talk in a public list" do
      visit talk_path(talk.id)
      find(:xpath, "//a[@title='Add to your list(s)']").click
      check list.name
      click_button 'Update'
      page.should have_no_content("added to ‘#{list.name}’")
    end
  end
end
