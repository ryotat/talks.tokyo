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
    it "should not list a private talk in a public list", :js => true do
      visit talk_path(talk.id)
      find(:xpath, "//a[@title='Add to your list(s)']").click
      check list.name
      wait_until { page.has_content? I18n.t(:cannot_add_to_public) }
      visit list_path(list)
      page.should have_no_content(talk.title)
    end
  end
end
