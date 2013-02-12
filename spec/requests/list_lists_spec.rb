# -*- coding: utf-8 -*-
require 'spec_helper'

describe "ListLists" do
  let(:user) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list, :name => "A public list", :organizer => user) }
  let(:private_list) { FactoryGirl.create(:list, :ex_directory => true) }
  before do
    sign_in user
    visit list_path(list.id)
    visit list_path(private_list.id)
    add_random_talks(private_list)
  end
  describe "create" do
    it "should not add a private list in a public list" do
      visit list_path(private_list.id)
      find(:xpath, "//a[@title='Add to your list(s)']").click
      check list.name
      click_button 'Update'
      page.should have_no_content("added to ‘#{list.name}’")
    end
  end
end
