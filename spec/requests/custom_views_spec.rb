require 'spec_helper'

describe "CustomViews" do
  let(:user) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list) }
  before do
    add_random_talks(list)
  end
  describe "index" do
    before do
      sign_in user
      visit list_path(list)
      click_link 'Create custom view'
    end
    it "should not show text SITE_NAME" do
      page.should_not have_content "SITE_NAME"
    end
    it "should generate a valid URL" do
      find(:css, 'div#viewurl a').click
      list.talks.each { |talk|
        if talk.start_time > beginning_of_day
          page.should have_content(talk.title)
        end
      }
    end
    ["index", "table", "minimalist", "detailed", "simplewithlogo", "oneday", "bulletin", "text", "xml", "rss", "ics"].each do |format|
      it "should respond to clicking #{format}", :js => true do
        choose "view_parameters_action_#{format}"
        wait_until { find('div#viewurl').has_content? format }
        without_q(path_of('div#viewurl a')).should == list_path(list,:format => format)
      end
    end
  end
end
