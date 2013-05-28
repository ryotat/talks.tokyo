# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Home",:js => true  do
  let(:talk1) { FactoryGirl.create(:talk, :start_time => Time.now) }
  let(:talk2) { FactoryGirl.create(:talk, :start_time => Time.now+6.days) }
  let(:talk3) { FactoryGirl.create(:talk, :start_time => Time.now+1.week) }
  subject { page }
  before do
    visit talk_path(talk1)
    visit talk_path(talk2)
    visit talk_path(talk3)
  end
  context "today's talks" do
    before do
      visit home_path
      click_link "Today"
    end
    it { within('div#tab-target') { should have_link(talk1.title) } }
    it { within('div#tab-target') { should have_no_link(talk2.title) } }
    it { within('div#tab-target') { should have_no_link(talk3.title) } }
  end
  context "this week's talks" do
    before do
      visit home_path
      click_link "This week"
    end
    it { within('div#tab-target') { should have_link(talk1.title) } }
    it { within('div#tab-target') { should have_link(talk2.title) } }
    it { within('div#tab-target') { should have_no_link(talk3.title) } }
  end
  context "all talks" do
    before do
      visit home_path
      click_link "All"
    end
    it { within('div#tab-target') { should have_link(talk1.title) } }
    it { within('div#tab-target') { should have_link(talk2.title) } }
    it { within('div#tab-target') { should have_link(talk3.title) } }
  end
end
