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
  describe "create", :js => true do
    subject { page }
    context "user only with a personal list" do
      let(:user1) { FactoryGirl.create(:user) }
      context "add" do
        before do
          sign_in user1
          visit list_path(list)
          find(:xpath, "//a[@title='Add to your list']").click
        end
        it { should have_content "Added ‘#{list.name}’ to your personal list" }
        
        context "remove" do
          before { find(:xpath, "//a[@title='Remove from your list']").click }
          it { should have_content "Removed ‘#{list.name}’ from your personal list" }
        end
      end
    end
    it "should not add a private list in a public list" do
      visit list_path(private_list.id, :locale => :en)
      find(:xpath, "//a[@title='Add/Remove from your lists']").click
      check list.name
      wait_until { page.has_content? I18n.t(:cannot_add_to_public, :locale => :en) }
      visit list_path(list)
      page.should have_no_content(private_list.name)
    end
  end
end
