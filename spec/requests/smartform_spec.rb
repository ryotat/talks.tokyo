# -*- coding: utf-8 -*-
require 'spec_helper'

describe "SmartForm", :js => true do
  let(:user) { FactoryGirl.create(:user) }
  before do
    sign_in user
    visit list_path(user.lists[0])
    click_link "Add a new talk"
    click_link "Just copy & paste into SmartForm"
  end
  context "UK date format" do
    before do
      fill_in 'inputbox', :with => <<EOF
Speaker:
Jonathan Livingston (Univ Tokyo)
Title:
About life as a seagull
Time:
Friday 12th October 2012, 13:30-15:00

Abstract:
Blablablablablablablablablablablablabla. Block1

Blablablablablablablablablablablablabla. Block2
EOF
      click_button "Apply"
    end
    specify { find(:xpath, "//input[@id='talk_title']").value.should == "About life as a seagull" }
    specify { find(:xpath, "//input[@id='talk_venue_name']").value.should ==  "Venue to be confirmed" }
    specify { find(:xpath, "//input[@id='talk_name_of_speaker']").value.should ==  "Jonathan Livingston (Univ Tokyo)" }
    specify { find(:xpath, "//input[@id='talk_date_string']").value.should ==  "2012/10/12" }
    specify { find(:xpath, "//input[@id='talk_start_time_string']").value.should ==  "13:30" }
    specify { find(:xpath, "//input[@id='talk_end_time_string']").value.should ==  "15:00" }
    specify { find(:xpath, "//textarea[@id='talk_abstract']").value.should ==  <<EOF
Blablablablablablablablablablablablabla. Block1

Blablablablablablablablablablablablabla. Block2
EOF
.strip()
    }
  end
  context "US format with venue" do
    before do
      fill_in 'inputbox', :with => <<EOF
Speaker:
Jonathan Livingston (Univ Tokyo)
Title:
About life as a seagull
Time:
Monday Aug 1st 2012, 09:30-09:40

Venue: 
University of Tokyo

Abstract:
Blablablablablablablablablablablablabla.
EOF
      click_button "Apply"
    end
    specify { find(:xpath, "//input[@id='talk_title']").value.should == "About life as a seagull" }
    specify { find(:xpath, "//input[@id='talk_venue_name']").value.should ==  "University of Tokyo" }
    specify { find(:xpath, "//input[@id='talk_name_of_speaker']").value.should ==  "Jonathan Livingston (Univ Tokyo)" }
    specify { find(:xpath, "//input[@id='talk_date_string']").value.should ==  "2012/8/1" }
    specify { find(:xpath, "//input[@id='talk_start_time_string']").value.should ==  "9:30" }
    specify { find(:xpath, "//input[@id='talk_end_time_string']").value.should ==  "9:40" }
    specify { find(:xpath, "//textarea[@id='talk_abstract']").value.should ==  "Blablablablablablablablablablablablabla."  }
  end
  context "AM to PM" do
    before do
      fill_in 'inputbox', :with => <<EOF
Speaker:
Jonathan Livingston (Univ Tokyo)
Title:
About life as a seagull
Time:
Monday July 2nd 2012, 10:30-13:00

Venue: 
University of Tokyo

Abstract:
Blablablablablablablablablablablablabla.
EOF
      click_button "Apply"
    end
    specify { find(:xpath, "//input[@id='talk_title']").value.should == "About life as a seagull" }
    specify { find(:xpath, "//input[@id='talk_venue_name']").value.should ==  "University of Tokyo" }
    specify { find(:xpath, "//input[@id='talk_name_of_speaker']").value.should ==  "Jonathan Livingston (Univ Tokyo)" }
    specify { find(:xpath, "//input[@id='talk_date_string']").value.should ==  "2012/7/2" }
    specify { find(:xpath, "//input[@id='talk_start_time_string']").value.should ==  "10:30" }
    specify { find(:xpath, "//input[@id='talk_end_time_string']").value.should ==  "13:00" }
    specify { find(:xpath, "//textarea[@id='talk_abstract']").value.should ==  "Blablablablablablablablablablablablabla."  }
  end
  context "compact format" do
    before do
      fill_in 'inputbox', :with => <<EOF
About life as a seagull
Speaker: Jonathan Livingston (Univ Tokyo)
@ University of Tokyo

2012/09/03 13:30-15:00
Abstract: Blablablablablablablablablablablablabla.
EOF
      click_button "Apply"
    end
    specify { find(:xpath, "//input[@id='talk_title']").value.should == "About life as a seagull" }
    specify { find(:xpath, "//input[@id='talk_venue_name']").value.should ==  "University of Tokyo" }
    specify { find(:xpath, "//input[@id='talk_name_of_speaker']").value.should ==  "Jonathan Livingston (Univ Tokyo)" }
    specify { find(:xpath, "//input[@id='talk_date_string']").value.should ==  "2012/9/3" }
    specify { find(:xpath, "//input[@id='talk_start_time_string']").value.should ==  "13:30" }
    specify { find(:xpath, "//input[@id='talk_end_time_string']").value.should ==  "15:00" }
    specify { find(:xpath, "//textarea[@id='talk_abstract']").value.should ==  "Blablablablablablablablablablablablabla." }
  end
  context "Multi-line title" do
    before do
      fill_in 'inputbox', :with => <<EOF
This is an extremely
long title that takes up multiple
lines
Speaker: Jonathan Livingston (Univ Tokyo)
@ University of Tokyo

2012/10/12 13:30-15:00
Abstract: Blablablablablablablablablablablablabla.
EOF
      click_button "Apply"
    end
    specify { find(:xpath, "//input[@id='talk_title']").value.should == "This is an extremely long title that takes up multiple lines" }
    specify { find(:xpath, "//input[@id='talk_venue_name']").value.should ==  "University of Tokyo" }
    specify { find(:xpath, "//input[@id='talk_name_of_speaker']").value.should ==  "Jonathan Livingston (Univ Tokyo)" }
    specify { find(:xpath, "//input[@id='talk_date_string']").value.should ==  "2012/10/12" }
    specify { find(:xpath, "//input[@id='talk_start_time_string']").value.should ==  "13:30" }
    specify { find(:xpath, "//input[@id='talk_end_time_string']").value.should ==  "15:00" }
    specify { find(:xpath, "//textarea[@id='talk_abstract']").value.should ==  "Blablablablablablablablablablablablabla." }
  end
  context "Japanese" do
    before do
      fill_in 'inputbox', :with => <<EOF
日時：平成２４年７月１３日(金曜）午後４時４０分～６時２０分
場所：東京大学XX学部
講師：山田太郎（東京大学）
講演タイトル(Title)：適当なタイトル
要旨(Abstract):
Blablablablablablablablablablablablabla.
EOF
      click_button "Apply"
    end
    specify { find(:xpath, "//input[@id='talk_title']").value.should == "適当なタイトル" }
    specify { find(:xpath, "//input[@id='talk_venue_name']").value.should ==  "東京大学XX学部" }
    specify { find(:xpath, "//input[@id='talk_name_of_speaker']").value.should ==  "山田太郎（東京大学）" }
    specify { find(:xpath, "//input[@id='talk_date_string']").value.should ==  "2012/7/13" }
    specify { find(:xpath, "//input[@id='talk_start_time_string']").value.should ==  "16:40" }
    specify { find(:xpath, "//input[@id='talk_end_time_string']").value.should ==  "18:20" }
    specify { find(:xpath, "//textarea[@id='talk_abstract']").value.should ==  "Blablablablablablablablablablablablabla." }

  end
  context "Japanese AM to PM" do
    before do
      fill_in 'inputbox', :with => <<EOF
日時 平成２４年７月１３日(金曜）午前10時3０分～12時3０分
場所 東京大学XX学部
講演者 山田太郎（東京大学）
講演タイトル 適当なタイトル
要旨
Blablablablablablablablablablablablabla.
EOF
      click_button "Apply"
    end
    specify { find(:xpath, "//input[@id='talk_title']").value.should == "適当なタイトル" }
    specify { find(:xpath, "//input[@id='talk_venue_name']").value.should ==  "東京大学XX学部" }
    specify { find(:xpath, "//input[@id='talk_name_of_speaker']").value.should ==  "山田太郎（東京大学）" }
    specify { find(:xpath, "//input[@id='talk_date_string']").value.should ==  "2012/7/13" }
    specify { find(:xpath, "//input[@id='talk_start_time_string']").value.should ==  "10:30" }
    specify { find(:xpath, "//input[@id='talk_end_time_string']").value.should ==  "12:30" }
    specify { find(:xpath, "//textarea[@id='talk_abstract']").value.should ==  "Blablablablablablablablablablablablabla." }

  end
  context "compact Japanese" do
    before do
      fill_in 'inputbox', :with => <<EOF
適当なタイトル
講演者：山田太郎（東京大学）

平成25年7月17日（水）15時～16時30分
@ 東京大学XX学部

Blablablablablablablablablablablablabla.
EOF
      click_button "Apply"
    end
    specify { find(:xpath, "//input[@id='talk_title']").value.should == "適当なタイトル" }
    specify { find(:xpath, "//input[@id='talk_venue_name']").value.should ==  "東京大学XX学部" }
    specify { find(:xpath, "//input[@id='talk_name_of_speaker']").value.should ==  "山田太郎（東京大学）" }
    specify { find(:xpath, "//input[@id='talk_date_string']").value.should ==  "2013/7/17" }
    specify { find(:xpath, "//input[@id='talk_start_time_string']").value.should ==  "15:00" }
    specify { find(:xpath, "//input[@id='talk_end_time_string']").value.should ==  "16:30" }
    specify { find(:xpath, "//textarea[@id='talk_abstract']").value.should ==  "Blablablablablablablablablablablablabla." }
  end
end
