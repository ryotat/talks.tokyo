# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Lists" do
  describe "Generate a link to post a talk" do
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, :users => [user]) }
    before do
      sign_in user
    end
    it "should show a link", :js => true do
      list_id = list.id
      old_password = list.talk_post_password
      visit list_path(:id => list_id)
      click_link "Show a link"
      list = List.find(list_id)
      list.talk_post_password.should == old_password
      page.should have_content new_posted_talk_path_for(list)
      page.should have_content "Generate a new one"
    end

    it "should generate a link", :js => true do
      list_id = list.id
      old_password = list.talk_post_password
      visit list_path(:id => list_id)
      click_link "Show a link"
      click_link "Generate a new one"
      wait_until { page.has_no_content? old_password }
      list = List.find(list_id)
      list.talk_post_password.should_not == old_password
      page.should have_content new_posted_talk_path_for(list)
    end
  end
  describe "choose" do
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, :users => [user]) }
    subject { page }
    before do
      sign_in user
      visit choose_lists_path
    end
    it { should_not have_content "talks.cam" }
    context "new list", :js => true do
      before do
        fill_in "list_name", :with => "A new list"
        click_button "Create"
        wait_until { page.has_content? "Successfully created" }
        click_link "A new list"
      end
      it { List.find(find(:xpath, "//input[@id='talk_series_id']").value).name.should == "A new list" }
    end
  end

  describe "new" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
    end
    it "should not say talks.cam" do
      visit new_list_path
      page.should_not have_content "talks.cam"
    end
  end

  describe "add/remove organizer" do
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, :organizer => user) }
    subject { page }
    context "for a non organizer" do
      let(:bad_user) { FactoryGirl.create(:user) }
      before do
        sign_in bad_user
        visit edit_list_path(list)
      end
      it { should have_no_content "Add or remove a manager of this list" }
    end
    context "for an organizer", :js => true do
      let(:usera) { FactoryGirl.create(:user, :email => "a@a.jp") }
      before do
        sign_in user
        visit edit_list_path(list)
        click_link "Add or remove a manager of this list"
      end
      context "add an organizer" do
        before do
          fill_in "list_user_user_email", :with => usera.email
          click_button "Add new manager"
          wait_until { page.has_content? usera.name }
        end
        it { should have_content usera.email }
        context "remove an organizer" do
          before do
            click_link "remove"
            wait_until { page.has_no_content? usera.name }
          end
          it { should have_no_content usera.email }
        end
      end
    end
  end

  describe "show included lists" do
    let(:user)  { FactoryGirl.create(:user) }
    let(:list1) { FactoryGirl.create(:list, :name => 'Interesting list', :organizer => user) }
    let(:list2) { FactoryGirl.create(:list) }
    let(:talk1) { FactoryGirl.create(:talk, :series => list1) }
    let(:talk2) { FactoryGirl.create(:talk, :series => list2) }
    let(:talk3) { FactoryGirl.create(:talk, :series => list2) }
    before do
      sign_in user
      visit talk_path(:id => talk1.id)
      visit talk_path(:id => talk2.id)
      visit talk_path(:id => talk3.id)
    end
    it "should not show talks in other lists" do
      visit list_path(:id => list1.id)
      within('div.index') do
        page.should have_content(talk1.title)
        page.should have_no_content(talk2.title)
        page.should have_no_content(talk3.title)
      end
    end
    it "should show talks in another list that is included in a list", :js => true do
      visit list_path(:id => list2.id)
      page.should have_content(talk2.title)
      find(:xpath, "//a[@title='Add/Remove from your list(s)']").click
      check list1.name
      wait_until { page.has_content? "added to ‘#{list1.name}’" }
      visit list_path(list1.id)
      within('div.index') do
        page.should have_content(talk1.title)
        page.should have_content(talk2.title)
        page.should have_content(talk3.title)
      end
    end
    it "should show a talk that is included in a list", :js => true do
      visit talk_path(:id => talk2.id)
      click_link 'Add/Remove from your list(s)'
      check list1.name
      wait_until { page.has_content? "added to ‘#{list1.name}’" }
      visit list_path(list1.id)
      within('div.index') do
        page.should have_content(talk1.title)
        page.should have_content(talk2.title)
        page.should have_no_content(talk3.title)
      end
    end
  end

  describe "show" do
    let(:list) { FactoryGirl.create(:list) }
    it "should show the year for a talk that is more than half a year ago" do
      talk = FactoryGirl.create(:talk, :start_time => 190.days.ago, :series => list)
      visit list_path(:id => list.id)
      within('div.simpletalk') do
        page.should have_content(talk.start_time.year)
      end
    end
    it "should show the year for a talk that is more than half a year away" do
      talk = FactoryGirl.create(:talk, :start_time => 190.days.from_now, :series => list)
      visit list_path(:id => list.id)
      within('div.simpletalk') do
        page.should have_content(talk.start_time.year)
      end
    end
    
  end
  describe "list" do
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, :organizer => user) }
    let(:talk) { FactoryGirl.create(:talk, :series => list) }
    before do
      sign_in user
      visit talk_path(:id => talk.id)
    end
    it "should not show deleted talks", :js => true do
      visit list_path(:id => list.id)
      page.should have_content(talk.title)
      visit talk_path(:id => talk.id)
      click_link 'Delete this talk'
      wait_until { page.has_content? "Are you sure?" }
      click_link 'Delete'
      visit list_path(:id => list.id)
      page.should have_no_content(talk.title)
      visit list_path(:id => 'all', :format => 'list', :layout => 'empty')
      page.should have_no_content(talk.title)
      visit edit_details_list_path(list)
      check 'list_ex_directory'
      click_button 'Save'
      visit list_path(:id => 'all', :format => 'list', :layout => 'empty')
      page.should have_no_content(talk.title)
      visit edit_details_list_path(list)
      uncheck 'list_ex_directory'
      click_button 'Save'
      visit list_path(:id => 'all', :format => 'list', :layout => 'empty')
      page.should have_no_content(talk.title)
    end
  end
end
