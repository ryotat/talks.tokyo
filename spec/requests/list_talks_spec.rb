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
  subject { page }
  context "existing talk", :js => true do
    before do
      open_talk_associations(talk)
    end
    context "new list" do
      before do
        fill_in 'list_name', :with => "A new list"
        click_button 'Create'
        wait_until { page.has_content? "Successfully created" }
      end
      it { should have_unchecked_field "A new list"  }
    end
  end
  context "remove from series", :js => true do
    let (:talk1) { FactoryGirl.create(:talk, :series => list) }
    before do
      open_talk_associations(talk1)
      uncheck talk1.series.name
      wait_until { page.has_content? "Cannot remove ‘#{talk1.title}’ from its series. " }
    end
    it { should have_checked_field talk1.series.name }
  end

  describe "create", :js => true do
    context "private talk" do
      let(:private_talk) { FactoryGirl.create(:talk, :title => "A private talk", :ex_directory => true) }
      before do 
        open_talk_associations(private_talk)
        check list.name
        wait_until { page.has_content? I18n.t(:cannot_add_to_public, :locale => I18n.locale) }
        visit list_path(list)
      end
      it { should have_no_content(talk.title) }
    end
  end
end
