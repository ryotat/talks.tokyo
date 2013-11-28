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
    context "new list" do
      before do
        visit list_path(list)
        click_link "Add/Remove from your lists"
        fill_in "list_name", :with => "A new public list"
        click_button "Create"
      end
      it { should have_content "Successfully created  ‘A new public list’" }
      it { should have_unchecked_field 'A new public list' }
    end
    context "try to add a private list in a public list" do
      before do
        visit list_path(private_list.id, :locale => :en)
        find(:xpath, "//a[@title='Add/Remove from your lists']").click
        check list.name
      end
      it { should have_content I18n.t(:cannot_add_to_public, :locale => :en) }
      context "then visit list" do
        before do
          visit list_path(list)
        end
        it { should have_no_content(private_list.name) }
      end
    end
  end
end
