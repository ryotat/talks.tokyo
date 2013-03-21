# -*- coding: utf-8 -*-
require 'spec_helper'

describe "ListUsers" do
  let (:user) { FactoryGirl.create(:user) }
  let (:list) { FactoryGirl.create(:list, :organizer => user) }
  subject { page }
  before do
    sign_in user
    visit edit_list_path(list)
    click_link "Add or remove a manager of this list"
  end
  it { should have_content "Managers of #{list.name}" }
  context "add", :js => true do
    let (:user1) { FactoryGirl.create(:user) }
    before do
      fill_in 'list_user_user_email', :with => user1.email
      click_button "Add new manager"
    end
    it { should have_content user1.name }
    it { should have_content "Successfully added #{user1.name} (#{user1.email})." }
    context "remove" do
      before do
        click_link "remove"
      end
      it { should have_content "Successfully removed #{user1.name} (#{user1.email})." }
    end
  end
  context "add non-existing user", :js => true do
    let(:email) { "nobody@example.com" }
    before do
      fill_in 'list_user_user_email', :with => email
      click_button "Add new manager"
    end
    it { should have_content "User with email #{email} does not exist" }
  end
end
