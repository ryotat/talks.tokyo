require 'spec_helper'

describe "PostedTalks" do
  describe "GET /posted_talks" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      visit posted_talks_path
      page.should have_content("You need to be logged in to carry this out.")
      # response.status.should be(302)
    end
  end
end
