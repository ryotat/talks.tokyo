# -*- coding: utf-8 -*-
require 'spec_helper'

describe "ListTalks" do
  let(:user) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list, :name => "A public list", :organizer => user) }
  let(:talk) { FactoryGirl.create(:talk) }
  before do
    sign_in user
    visit list_path(list.id)
  end
  describe "create", :js => true do
    subject { page }
    context "private talk" do
      let(:private_talk) { FactoryGirl.create(:talk, :title => "A private talk", :ex_directory => true) }
      before do 
        visit talk_path(private_talk)
        click_link 'Add/Remove from your list(s)'
        check list.name
        wait_until { page.has_content? I18n.t(:cannot_add_to_public) }
        visit list_path(list)
      end
      it { should have_no_content(talk.title) }
    end
    context "new list" do
      before do
        visit talk_path(talk)
        click_link 'Add/Remove from your list(s)'
        wait_until { page.has_content? "Which lists would you like to include" }
        fill_in 'list_name', :with => "A new list"
        click_button 'Create'
        wait_until { page.has_content? "Successfully created" }
      end
      it { should have_unchecked_field "A new list"  }
    end
  end
end
