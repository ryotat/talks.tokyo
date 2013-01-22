# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Home",:js => true  do
  let(:talk1) { FactoryGirl.create(:talk, :start_time => Time.now) }
  let(:talk2) { FactoryGirl.create(:talk, :start_time => Time.now+6.days) }
  let(:talk3) { FactoryGirl.create(:talk, :start_time => Time.now+1.week) }
  before do
    visit talk_path(:id => talk1.id)
    visit talk_path(:id => talk2.id)
    visit talk_path(:id => talk3.id)
  end
  it "should show today's talks" do
    visit home_path
    click_link "Today"
    page.should have_link(talk1.title)
    page.should have_no_link(talk2.title)
    page.should have_no_link(talk3.title)
  end
  it "should show this week's talks" do
    visit home_path
    click_link "This week"
    page.should have_link(talk1.title)
    page.should have_link(talk2.title)
    page.should have_no_link(talk3.title)
  end
  it "should show all talks" do
    visit home_path
    click_link "All"
    page.should have_link(talk1.title)
    page.should have_link(talk2.title)
    page.should have_link(talk3.title)
  end
end
