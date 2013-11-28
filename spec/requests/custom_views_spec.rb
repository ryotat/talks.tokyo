require 'spec_helper'

describe "CustomViews" do
  let(:user) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list) }
  before do
    add_random_talks(list)
  end
  describe "index", :js => true do
    before do
      sign_in user
      visit list_path(list)
      page.find('i.icon-cog').click
      click_link 'Create custom view'
    end
    it "should not show text SITE_NAME" do
      page.should_not have_content "SITE_NAME"
    end
    context "should generate a valid URL" do
      before do
        visit find('div#viewurl a')[:href]
      end
      specify do
        list.talks.each { |talk|
          if talk.start_time > beginning_of_day
            page.should have_content(talk.title)
          else
            page.should have_no_content(talk.title)
          end
        }
      end
    end
    ["index", "table", "minimalist", "detailed", "simplewithlogo", "oneday", "bulletin", "text", "xml", "rss", "ics"].each do |format|
      context "#{format}" do
        before do
          choose "view_parameters_action_#{format}"
          sleep(1)
        end
        specify { find('div#viewurl').should have_content format }
        specify { without_q(path_of('div#viewurl a')).should == list_path(list,:format => format) }
      end
    end
  end
end
