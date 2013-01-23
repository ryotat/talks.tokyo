require 'spec_helper'

describe "CustomViews" do
  describe "index" do
    let(:list) { FactoryGirl.create(:list) }
    before do
      add_random_talks(list)
      visit "/custom_view?list=#{list.id}"
    end
    it "should not show text SITE_NAME" do
      page.should_not have_content "SITE_NAME"
    end
    it "should generate a valid URL" do
      find(:css, 'div#viewurl a').click
      list.talks.each { |talk|
        page.should have_content(talk.title)
      }
    end
  end
end
