require 'spec_helper'

describe "Tickles" do
  describe "create" do
    let(:talk) { FactoryGirl.create(:talk) }
    it "should not let non-user to send email" do
      visit '/tickles/create/1?tickle[about_id]=1&tickle[about_type]=Talk&tickle[recipient_email]=a@a.jp'
      page.should have_content "You need to be logged in to carry this out."
    end
  end
end
