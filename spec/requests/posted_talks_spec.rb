require 'spec_helper'

describe "PostedTalks" do
  describe "index" do
    let(:user) { find_or_create(User,:albert) }
    before do
      sign_in user
    end
    it "should not index talks for non-administrator" do
      visit posted_talks_path
      page.should have_content("The page you were looking for doesn't exist")
    end
    it "should index talks when list_id is specified" do
      list = FactoryGirl.create(:list, :organizer => :albert)
      visit posted_talks_path(:list_id => list.id)
      page.should_not have_content("Sorry, you do not have permission for that action")
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
      page.should have_content("Sorry, you do not have permission for that action")
    end
    it "should show talk when the user is the speaker" do
      talk = FactoryGirl.create(:posted_talk, :speaker => :albert, :organizer => :bob)
      visit posted_talk_path(talk.id)
      page.should_not have_content("Sorry, you do not have permission for that action")
    end
    it "should show talk when the user is an organizer" do
      bob = FactoryGirl.create(:bob)
      talk = FactoryGirl.create(:posted_talk, :title => "Bob's talk", :speaker => :bob, :organizer => :albert)
      visit posted_talk_path(talk.id)
      page.should have_content("Bob's talk")
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
      page.should have_content("Sorry, you do not have permission for that action")
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
      save_and_open_page
      page.should have_content(talk.title)
      page.should have_content(talk.speaker.name)
    end
  end
end
