# -*- coding: utf-8 -*-
require 'spec_helper'
require "rexml/document"

shared_examples "personal list" do
  it "should have all the talks" do
    user.personal_list.talks.each do |talk|
      page.should have_content talk.title
    end
  end
end

shared_examples "show talks in specified period" do
  it do
    list.talks.each do |t| 
      if t.start_time >= start_time && t.start_time < end_time
        page.should have_content t.title
      else
        page.should have_no_content t.title
      end
    end
  end
end

shared_examples "show talks in ascending order" do
  specify do
    all(:css,"div.simpletalk h2 a").map(&:text).join("").should =~ Regexp.new(list.talks.where(["start_time >= ? and start_time < ?", start_time, end_time]).sort_by(&:start_time).map(&:title).join(".*"))
  end
end

shared_examples "show talks in descending order" do
  specify do
    all(:css,"div.simpletalk h2 a").map(&:text).join("").should =~ Regexp.new(list.talks.where(["start_time >= ? and start_time < ?", start_time, end_time]).order("talks.start_time DESC").map(&:title).join(".*"))
  end
end

shared_context "user is a manager", :user => :list_manager do
  before do
    sign_in list.users[0]
  end
end

describe "Lists" do
  context "new" do
    let(:user) { FactoryGirl.create(:user) }
    subject { page }
    before do
      sign_in user
      visit new_list_path
    end
    it { should have_no_content "talks.cam" }
    it { should have_xpath("//input[@id='list_name']") }
    it { should have_xpath("//textarea[@id='list_details']") }
    it { should have_xpath("//select[@id='list_default_language']") }
    it { should have_xpath("//input[@id='list_mailing_list_address']") }
    context "create" do
      before do
        fill_in "list_name", :with => "A new list"
        fill_in "list_details", :with => "Some details"
        click_button "Save"
      end
      it { should have_content "A new list" }
      it { should have_content "Some details" }
    end
    context "empty name" do
      before do
        click_button "Save"
      end
      it { should have_content "Nameを入力してください" }
    end
    context "script attack", :js => true do
      before do
        fill_in "list_name", :with => bad_script
        fill_in "list_details", :with => bad_script
        click_button "Save"
      end
      it { should have_content bad_script }
      it { should have_no_xpath("//b", :text => "I got you") }
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
      visit list_path(:id => list1.id, :period => 'all')
      within('div.index') do
        page.should have_content(talk1.title)
        page.should have_no_content(talk2.title)
        page.should have_no_content(talk3.title)
      end
    end
    it "should show talks in another list that is included in a list", :js => true do
      visit list_path(:id => list2.id, :period => 'all')
      page.should have_content(talk2.title)
      find(:xpath, "//a[@title='Add/Remove from your lists']").click
      check list1.name
      wait_until { page.has_content? "Added ‘#{list2.name}’ to ‘#{list1.name}’" }
      visit list_path(list1.id, :period => 'all')
      within('div.index') do
        page.should have_content(talk1.title)
        page.should have_content(talk2.title)
        page.should have_content(talk3.title)
      end
    end
    it "should show a talk that is included in a list", :js => true do
      visit talk_path(:id => talk2.id)
      click_link 'Add/Remove from your lists'
      check list1.name
      wait_until { page.has_content? "Added ‘#{talk2.name}’ to ‘#{list1.name}’" }
      visit list_path(list1.id, :period => 'all')
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
      visit list_path(:id => list.id, :period => 'all')
      within('div.simpletalk') do
        page.should have_content(talk.start_time.year)
      end
    end
    it "should show the year for a talk that is more than half a year away" do
      talk = FactoryGirl.create(:talk, :start_time => 190.days.from_now, :series => list)
      visit list_path(:id => list.id, :period => 'all')
      within('div.simpletalk') do
        page.should have_content(talk.start_time.year)
      end
    end
    context "past and future" do
      before do
        (-3..3).map { |x| FactoryGirl.create(:talk, :series => list, :start_time => Time.now + x.day) }
      end
      context "period not specified" do
        let(:start_time) { beginning_of_day }
        let(:end_time)   { Time.now + 3.days }
        before do 
          visit list_path(list, :layout => 'empty') 
        end
        it_should_behave_like "show talks in specified period"
        it_should_behave_like "show talks in ascending order"
      end
      context "start_time given" do
        let(:start_time) {  (Time.now-1.day).at_beginning_of_day }
        let(:end_time)   { Time.now + 4.days }
        before do
          visit list_path(list, :start_time => start_time.iso8601, :layout => 'empty')
        end
        it_should_behave_like "show talks in specified period"
      end
      context "end_time after today" do
        let(:start_time) { beginning_of_day }
        let(:end_time) { (Time.now+1.day).at_beginning_of_day }
        before do
          visit list_path(list, :end_time => end_time.iso8601, :layout => 'empty')
        end
        it_should_behave_like "show talks in specified period"
        it_should_behave_like "show talks in ascending order"
      end
      context "end_time before today" do
        let(:start_time) { Time.now-4.days }
        let(:end_time) { (Time.now-1.day).at_beginning_of_day }
        before do
          visit list_path(list, :end_time => end_time.iso8601, :layout => 'empty')
        end
        it_should_behave_like "show talks in specified period"
        it_should_behave_like "show talks in descending order"
      end
    end
    context "only past" do
      let(:start_time) { Time.now-4.days }
      let(:end_time) { Time.now }
      before do
        (-3..-1).map { |x| FactoryGirl.create(:talk, :series => list, :start_time => Time.now + x.day) }
        visit list_path(list) 
      end          
      it_should_behave_like "show talks in descending order"
    end

    context "detailed" do
      before do
        add_random_talks(list)
        visit list_path(list, :period => 'all', :format => :detailed)
      end
      it { list.talks.each { |t| page.should have_content t.title } }
    end
    context "rss" do
      before do
        add_random_talks(list)
        visit list_path(list, :format => :rss)
      end
      subject { Nokogiri::XML(page.source) }
      it { subject.xpath("//managingEditor").text.should_not include list.users.first.email }
      context "description" do
        subject { Nokogiri::HTML(Nokogiri::XML(page.source).xpath("//item/description").text) }
        it { list.talks.each { |t| should have_link 'Add to your calendar', href:talk_url(t, :format => :ics) } }
        it { list.talks.each { |t| should have_link 'Include in your list', href:new_talk_association_url(t) } }
      end
    end
  end
  context "personal_list" do
    subject { page }
    let(:user) { FactoryGirl.create(:user) }
    before do
      visit list_path(user.personal_list)
    end
    it { should have_content "The page you were looking for doesn't exist." }
    context "allows" do
      before do
        add_random_talks(user.personal_list)
      end
      context "rss" do
        before do
          visit list_path(user.personal_list, :format => :rss)
        end
        it_behaves_like "personal list"
      end
      context "email" do
        before do
          visit list_path(user.personal_list, :format => :email)
        end
        it_behaves_like "personal list"
      end
      context "ics" do
        before do
          visit list_path(user.personal_list, :format => :ics)
        end
        it_behaves_like "personal list"
      end
    end
    context "another user" do
      let(:another_user) { FactoryGirl.create(:user) }
      before do
        sign_in another_user
        visit list_path(user.personal_list)
      end
      it { should have_content "The page you were looking for doesn't exist." }
    end
  end

  describe "list" do
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, :organizer => user) }
    let(:list_id) { list.id }
    let(:talk) { FactoryGirl.create(:talk, :series => list) }
    subject { page }
    before do
      sign_in user
      sign_out
      visit talk_path(:id => talk.id)
    end

    context "deleted talks", :user => :list_manager do
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

    context "Generate a link to post a talk", :js => true do
      context "for a manager", :user => :list_manager do
        before do
          visit list_path(list)
          click_link "Show a link"
          wait_until { page.has_content? "Copy and paste this URL into an email (note that anyone with this URL can make a request!)" }
        end
        it "should show a link" do
          list = List.find(list_id)
          page.should have_content new_posted_talk_path_for(list)
          page.should have_content "Generate a new one"
        end

        context "Genenerate new" do
          before do
            list = List.find(list_id)
            old_password = list.talk_post_password
            click_link "Generate a new one"
            wait_until { page.has_no_content? old_password }
          end
          it "should generate a link" do
            list = List.find(list_id)
            page.should have_content new_posted_talk_path_for(list)
          end
        end
      end
    end

    context "choose" do
      context "not logged in" do
        before do
          visit home_path
        end
        it { should have_content "Add a new talk" }
        context "Add" do
          before do
            click_link "Add a new talk"
          end
          it { should have_content "You need to be logged in to carry this out" }
          context "for a manager" do
            before do
              fill_in 'email', :with => user.email
              fill_in 'password', :with => user.password
              click_button 'Log in'
            end
            it { should have_content "Which list would you like to add a talk to?" }
            it { should have_xpath "//li/a[contains(.,\"#{list.name}\")]" }
            it { should have_xpath("//div", :text => "You have been logged in.") }
            context "chosen" do
              before do
                click_link list.name
              end
              specify { current_full_path.should == new_talk_path(:list_id => list.id) }
            end
          end
          context "for a new user" do
            before do
              click_link "create one"
              fill_in 'user_email', :with => 'abc@abc.jp'
              fill_in 'user_password', :with => 'blabla'
              fill_in 'user_password_confirmation', :with => 'blabla'
              click_button 'Sign up'
              click_button 'Save details'
              find(:xpath, "//a[@href='/login/return_to_original_url']").click
            end
            it { should have_content "Which list would you like to add a talk to?" }
          end
        end
      end
      context "manager", :user => :list_manager do      
        before do
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
    end
    
    context "edit", :user => :list_manager do
      before do
        visit list_path(list)
        click_link "Edit this list"
        click_link "Edit the name, description or picture of this list"
      end
      it { should have_xpath("//input[@id='list_name']") }
      it { should have_xpath("//textarea[@id='list_details']") }
      it { should have_xpath("//select[@id='list_default_language']") }
      it { should have_xpath("//input[@id='list_mailing_list_address']") }
      it { should have_xpath("//input[@id='list_hue']") }
      it { should have_xpath("//input[@id='list_image']") }
      it { should have_xpath("//input[@id='list_ex_directory']") }
      context "update" do
        before do
          fill_in 'list_name', :with => "A different name"
          fill_in 'list_details', :with => "More details"
          click_button "Save"
          visit list_path(list)
        end
        it { should have_content "A different name" }
        it { should have_content "More details" }
      end
      context "empty name" do
        before do
          fill_in 'list_name', :with => ""
          click_button "Save"
        end
        it { should have_content "Nameを入力してください" }
        it { should have_xpath("//input[@id='list_name']") }
      end
      context "invalid mailing list address" do
        before do
          fill_in 'list_mailing_list_address', :with => "bla@bla"
          click_button "Save"
        end
        it { should have_content "Mailing list address is invalid" }
        it { should have_xpath("//input[@id='list_mailing_list_address']") }
      end
    end

    context "edit details", :js => true do
      context "for a non-organizer", :user => :visitor do
        before do
          visit list_path(list)
        end
        it { should have_no_link I18n.t(:edit), href:edit_details_list_path(list) }
      end
      context "for an organizer", :user => :list_manager do
        before do
          visit list_path(list)
          within('.details') { click_link I18n.t(:edit) }
        end
        specify { current_full_path.should == edit_details_list_path(list) }
      end
      context "list with many ps", :user => :list_manager do
        let(:list2) { FactoryGirl.create(:list, :organizer => user, :details => <<eos
1st line

2nd line

3rd line
eos
                                         ) }
        before do
          visit list_path(list2)
        end
        it { should have_xpath("//a[@href='#{edit_details_list_path(list2)}']", :count => 1) }
      end
    end

    context "delete", :user => :list_manager do
      before do
        visit list_path(list)
        click_link "Edit this list"
        click_link "Delete this list"
      end
      it { should have_content "List ‘#{list.name}’ has been deleted." }
    end

    context "add/remove organizer" do
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
        context "add non-existing user" do
          let(:email) { "nobody@example.com" }
          before do
            fill_in 'list_user_user_email', :with => email
            click_button "Add new manager"
          end
          it { should have_content "User with email #{email} does not exist" }
        end
        context "add an organizer" do
          before do
            fill_in "list_user_user_email", :with => usera.email
            click_button "Add new manager"
            wait_until { page.has_content? "Successfully added" }
          end
          it { should have_content "Successfully added #{usera.name} (#{usera.email})." }
          context "remove an organizer" do
            before do
              click_link "remove"
              wait_until { page.has_content? "Successfully removed" }
            end
            it { should have_content "Successfully removed #{usera.name} (#{usera.email})." }
          end
        end
      end
    end
  end
end
