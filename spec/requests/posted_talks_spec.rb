require 'spec_helper'

describe "PostedTalks" do
  describe "index" do
    let(:user) { find_or_create(User,:albert) }
    before do
      sign_in user
    end
    it "should not index talks for non-administrator" do
      visit posted_talks_path
      page.should show_404
    end
    it "should index talks when list_id is specified" do
      list = FactoryGirl.create(:list, :organizer => :albert)
      visit posted_talks_path(:list_id => list.id)
      page.should_not show_403
    end
    it "should only index talks belonging to the user" do
      list = FactoryGirl.create(List, :organizer => :albert)
      FactoryGirl.create(:posted_talk, :title => "A talk in Albert's list", :series => list)
      FactoryGirl.create(:posted_talk, :title => "A talk in Bob's list", :organizer => :bob)
      visit posted_talks_path(:list_id => list.id)
      page.should_not have_content("A talk in Bob's list")
      page.should have_content("A talk in Albert's list")
    end
  end
  describe "show" do
    let(:user) { FactoryGirl.create(:albert) }
    before do
      sign_in user
    end
    it "should not show talk when the user is a stranger" do
      talk = FactoryGirl.create(:posted_talk, :speaker => :user, :organizer => :bob)
      visit posted_talk_path(talk.id)
      page.should show_403
    end
    it "should show talk when the user is the speaker" do
      talk = FactoryGirl.create(:posted_talk, :speaker => :albert, :organizer => :bob)
      visit posted_talk_path(talk.id)
      page.should_not show_403
    end
    it "should show talk when the user is an organizer" do
      bob = FactoryGirl.create(:bob)
      talk = FactoryGirl.create(:posted_talk, :title => "Bob's talk", :speaker => :bob, :organizer => :albert)
      visit posted_talk_path(talk.id)
      page.should have_content(talk.title)
      page.should have_link("Approve this talk")
    end
  end
  
  describe "approve" do
    let(:user) { FactoryGirl.create(:albert) }
    before do
      sign_in user
    end
    it "should not allow the speaker to approve his talk" do
      talk = FactoryGirl.create(:posted_talk, :speaker => :albert, :organizer => :bob)
      visit approve_posted_talk_path(talk.id)
      page.should show_403
    end
    it "should render edit when the time is not fully specified" do
      bob = FactoryGirl.create(:bob)
      talk = FactoryGirl.create(:posted_talk, :speaker => :bob, :organizer => :albert)
      visit approve_posted_talk_path(talk.id)
      page.should have_content("Time or venue not fully specified.")
    end

    it "should approve" do
      bob = FactoryGirl.create(:bob)
      talk = FactoryGirl.create(:posted_talk, :title => "Bob's talk", :speaker => :bob, :organizer => :albert, :start_time => Time.now, :end_time => Time.now + 1.hour, :venue => FactoryGirl.create(:venue))
      visit approve_posted_talk_path(talk.id)
      page.should have_content(talk.title)
      page.should have_content(talk.speaker.name)
    end
  end
  
  describe "new" do
    let(:user) { FactoryGirl.create(:albert) }
    let(:list) { FactoryGirl.create(:list, :organizer => :bob) }
    before do
      sign_in user
    end
    it "should show edit page" do
      visit new_posted_talk_path(:list_id => list.id, :key => list.talk_post_password)
      page.should have_content("Title")
      page.should have_selector("input#posted_talk_title")
    end
  end

  describe "edit"  do
    let(:user) { FactoryGirl.create(:albert) }
    let(:talk) { FactoryGirl.create(:posted_talk, :speaker => :albert, :organizer => :bob) }
    before do
      sign_in user
      visit edit_posted_talk_path(talk)
    end
    it "should allow the speaker to edit" do
      page.should have_content("Title")
      page.should have_selector("input#posted_talk_title")
    end
    it "should show help when title is focussed", :js => true do
      fill_in 'posted_talk_title', :with => 'A New Title Bla Bla'
      page.should have_content("If you do not know the title at this stage, please leave it as")
    end
    it "should show help when date is focussed", :js => true do
      fill_in 'posted_talk_date_string', :with => Time.now.strftime("%Y/%m/%d")
      page.should have_content("Please enter the date of the talk in the form YYYY/MM/DD e.g. 2007/12/13, or pick it out with this calendar")
      page.should have_content("Select date")
    end
  end
end
