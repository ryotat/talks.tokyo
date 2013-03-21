# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Search" do
  subject { page }
  before do
    visit home_path
  end
  context "talk" do
    let(:talk) { FactoryGirl.create(:talk, :title => "The title", :abstract => "The abstract")  }
    context "with title" do
      before do
        fill_in 'search', :with => talk.title
        click_button 'Go'
      end
      it { should have_link_to talk_path(talk, :locale => I18n.locale) }
    end
    context "with abstract" do
      before do
        fill_in 'search', :with => talk.abstract
        click_button 'Go'
      end
      it { should have_link_to talk_path(talk, :locale => I18n.locale) }
    end
  end
  context "list" do
    let(:list) { FactoryGirl.create(:list, :name => "A new list", :details => "The details of the list") }
    context "with name" do
      before do
        fill_in 'search', :with => list.name
        click_button 'Go'
      end
      it { should have_link_to list_path(list, :locale => I18n.locale) }
    end
    context "with details" do
      before do
        fill_in 'search', :with => list.details
        click_button 'Go'
      end
      it { should have_link_to list_path(list, :locale => I18n.locale) }
    end
  end
end
