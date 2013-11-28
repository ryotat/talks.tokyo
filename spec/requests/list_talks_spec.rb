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
    it_should_behave_like "association_dialog"
    context "new list" do
      before do
        fill_in 'list_name', :with => "A new list"
        click_button 'Create'
      end
      it { should have_content "Successfully created" }
      it { should have_unchecked_field "A new list"  }
    end
    context "associate with a public list" do
      before do
        check list.name
      end
      it { should have_content "Added ‘#{talk.name}’ to ‘#{list.name}’" }
      context "then visit list" do
        before do
          sleep(1)
          visit list_path(list, :layout => :empty)
        end
        it { should have_xpath("//a[contains(@href,'#{talk_path(talk)}')][contains(.,'#{talk.title}')]", :count => 1) }
      end
      context "associate with two lists" do
        let(:list2) { FactoryGirl.create(:list, :name => "Another public list", :organizer => user) }
        before do
          check list2.name
          sleep(1)
        end
        it { should have_content "Added ‘#{talk.name}’ to ‘#{list2.name}’" }
        context "add list to another list" do
          before do
            open_list_associations(list)
            check list2.name            
          end
          it { should have_content "Added ‘#{list.name}’ to ‘#{list2.name}’" }
          context "then visit another list" do
            before do
              visit list_path(list2, :layout => :empty)
            end
            it { should have_xpath("//a[contains(@href,'#{talk_path(talk)}')][contains(.,'#{talk.title}')]", :count => 1) }
          end
        end
      end
    end
  end

  context "remove from series", :js => true do
    let (:talk1) { FactoryGirl.create(:talk, :series => list) }
    before do
      open_talk_associations(talk1)
      uncheck talk1.series.name
    end
    it { should have_content "Cannot remove ‘#{talk1.title}’ from its series. " }
    it { should have_checked_field talk1.series.name }
  end

  describe "create", :js => true do
    context "private talk" do
      let(:private_talk) { FactoryGirl.create(:talk, :title => "A private talk", :ex_directory => true) }
      before do 
        open_talk_associations(private_talk)
        check list.name
      end
      it { should have_content I18n.t(:cannot_add_to_public, :locale => I18n.locale) }
      context "then visit list" do
        before { visit list_path(list) }
        it { should have_no_content(talk.title) }
      end
    end
  end
end
