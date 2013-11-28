require 'spec_helper'

describe "PostedTalks" do
  describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
    end
    it "should not index talks for non-administrator" do
      visit posted_talks_path
      page.should show_404
    end
    it "should index talks when list_id is specified" do
      list = FactoryGirl.create(:list, :organizer => user)
      visit posted_talks_path(:list_id => list.id)
      page.should_not show_403
    end
    it "should only index talks belonging to the user" do
      bob = FactoryGirl.create(:bob)
      list = FactoryGirl.create(List, :organizer => user)
      FactoryGirl.create(:posted_talk, :title => "A talk in #{user.name}'s list", :series => list)
      FactoryGirl.create(:posted_talk, :title => "A talk in Bob's list", :organizer => bob)
      visit posted_talks_path(:list_id => list.id)
      page.should_not have_content("A talk in Bob's list")
      page.should have_content("A talk in #{user.name}'s list")
    end
  end
  describe "show" do
    let(:user) { FactoryGirl.create(:user) }
    let(:bob) { FactoryGirl.create(:bob) }
    before do
      sign_in user
    end
    it "should not show talk when the user is a stranger" do
      albert = FactoryGirl.create(:albert)
      talk = FactoryGirl.create(:posted_talk, :speaker => albert, :organizer => bob)
      visit posted_talk_path(talk.id)
      page.should show_403
    end
    it "should show talk when the user is the speaker" do
      talk = FactoryGirl.create(:posted_talk, :speaker => user, :organizer => bob)
      visit posted_talk_path(talk.id)
      page.should_not show_403
      page.should_not have_link("Approve this talk")
    end
    it "should show talk when the user is an organizer" do
      bob = FactoryGirl.create(:bob)
      talk = FactoryGirl.create(:posted_talk, :title => "Bob's talk", :speaker => bob, :organizer => user)
      visit posted_talk_path(talk.id)
      page.should have_content(talk.title)
      page.should have_link("Approve this talk")
    end
  end
  
  describe "approve" do
    let(:user) { FactoryGirl.create(:user) }
    let(:bob) { FactoryGirl.create(:bob) }
    before do
      sign_in user
    end
    it "should not allow the speaker to approve his talk" do
      talk = FactoryGirl.create(:posted_talk, :speaker => user, :organizer => bob)
      visit approve_posted_talk_path(talk.id)
      page.should show_403
    end
    it "should not allow a stranger to approve his talk" do
      new_user = FactoryGirl.create(:user)
      talk = FactoryGirl.create(:posted_talk, :speaker => user, :organizer => bob)
      visit approve_posted_talk_path(talk.id)
      page.should show_403
    end
    it "should render edit when the time is not fully specified" do
      talk = FactoryGirl.create(:posted_talk, :speaker => bob, :organizer => user)
      visit approve_posted_talk_path(talk.id)
      page.should have_content("Time or venue not fully specified.")
    end

    it "should approve" do
      talk = FactoryGirl.create(:posted_talk, :title => "Bob's talk", :speaker => bob, :organizer => user, :start_time => Time.now, :end_time => Time.now + 1.hour, :venue => FactoryGirl.create(:venue))
      visit approve_posted_talk_path(talk.id)
      page.should have_content(talk.title)
      page.should have_content(talk.speaker.name)
    end
  end
  
  describe "new" do
    let(:list) { FactoryGirl.create(:list) }
    it "should show edit page" do
      visit new_posted_talk_path(:list_id => list.id, :key => list.talk_post_password)
      page.should have_content("Title")
      page.should have_selector("input#posted_talk_title")
    end
    it "should not show edit page when the key is not correct" do
      visit new_posted_talk_path(:list_id => list.id, :key => "wrong")
      page.should show_403
    end
    it "should fill name and email when logged in" do
      user = FactoryGirl.create(:user)
      # page.css('input#posted_talk_name_of_speaker').val.should == user.name
    end
  end

  describe "create" do
    let(:list) { FactoryGirl.create(:list) }
    let(:speaker_name) { "My Name" }
    let(:speaker_email) { "me@talks.tokyo" }
    before do
      host! 'localhost:3000'
      visit new_posted_talk_path(:list_id => list.id, :key => list.talk_post_password)
      fill_in "posted_talk_title", :with => "The title"
      fill_in "posted_talk_name_of_speaker", :with => speaker_name
      fill_in "posted_talk_speaker_email", :with => speaker_email
      click_button "Submit"
    end
    it "should look OK" do
      page.should have_content("The title")
      page.should have_content(speaker_name)
      page.should_not have_content("Approve this talk")
    end
    it "should send email with password" do
      last_email(2).to.should include(speaker_email)
      last_email(2).body.should include("password")
      last_email(2).body.should include(login_url)
      last_email(2).body.should include(SITE_NAME)
    end
    it "should send organizers an email" do
      list.users.each { |user| last_email.to.should include(user.email) }
      last_email.body.should include(speaker_name)
      last_email.body.should include(speaker_email)
      last_email.body.should include("To approve this talk, click")
    end
  end
  describe "edit"  do
    let(:user) { FactoryGirl.create(:user) }
    let(:bob)  { FactoryGirl.create(:bob) }
    let(:talk) { FactoryGirl.create(:posted_talk, :speaker => user, :organizer => bob) }
    before do
      sign_in user
      visit edit_posted_talk_path(talk)
    end
    it "should allow the speaker to edit" do
      page.should have_content("Title")
      page.should have_selector("input#posted_talk_title")
    end
    it "should open SmartForm", :js => true do
      page.should have_selector('div#smartform', visible: false)
      click_link "Just copy & paste into SmartForm"
      page.should have_selector('div#smartform', visible: true)
    end
    it "should show help when title is focussed", :js => true do
      fill_in 'posted_talk_title', :with => 'A New Title Bla Bla'
      page.should have_content("If you do not know the title at this stage, please leave it as")
    end
    it "should show help when date is focussed", :js => true do
      page.find('#posted_talk_date_string').trigger(:focus)
      page.should have_content("Please enter the date of the talk in the form YYYY/MM/DD, e.g. 2007/12/13")
    end
    it "should let user click a date", :js => true do
      page.find('#posted_talk_date_string').trigger(:focus)
      d = Time.zone.now.beginning_of_month
      click_link d.day.to_s
      find(:xpath,"//input[@id='posted_talk_date_string']").value.should == d.strftime("%Y/%m/%d")
    end
  end
end
