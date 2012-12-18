require 'spec_helper'

describe "CustomViews" do
  describe "index" do
    let(:list) { FactoryGirl.create(:list) }
    it "should not show text SITE_NAME" do
      visit "/custom_view?list=#{list.id}"
      page.should_not have_content "SITE_NAME"
    end
  end
end
