# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Users" do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }
  context "create" do
    subject { page }
    before do
      visit home_path(:locale => :en)
      click_link "Create an account"
    end
    context "valid" do
      before do
        fill_in "user_email", :with => "user@example.com"
        fill_in "user_password", :with => "password"
        fill_in "user_password_confirmation", :with => "password"
        click_button "Sign up"
      end
      it { should have_content "A new account has been created." }
      context "and login" do
        before do
          visit login_path
          fill_in "email", :with => "user@example.com"
          fill_in "password", :with => "password"
          click_button "Log in"
        end
        it { should have_content "You have been logged in." }
      end
    end
    context "password does not match" do
      before do
        fill_in "user_email", :with => "user@example.com"
        fill_in "user_password", :with => "password"
        fill_in "user_password_confirmation", :with => "password_wrong"
        click_button "Sign up"
      end
      it { should have_content "Password doesn't match confirmation" }
    end
    context "user exists" do
      before do
        fill_in "user_email", :with => user.email
        fill_in "user_password", :with => "password"
        fill_in "user_password_confirmation", :with => "password"
        click_button "Sign up"
      end
      it { should have_content "address is already registered on the system"}
    end
    
  end
  describe "show" do
    it "should not show the full email" do
      bob = FactoryGirl.create(:bob)
      sign_in bob
      visit user_path(:id => user.id)
      page.should_not have_xpath("//a[@href = 'mailto:#{user.email}']")
    end
    it "should not show ex_directory talks", :js => true do
      talk = FactoryGirl.create(:talk, :name_of_speaker => user.name, :speaker_email => user.email)
      visit talk_path(talk)
      sign_in user
      visit user_path(user)
      page.should have_content(talk.title)
      visit talk_path(talk)
      click_link 'Delete this talk'
      wait_until { page.has_content? "Are you sure?" }
      click_link 'Delete'
      visit user_path(user)
      page.should have_no_content(talk.title)
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      click_link 'Edit your details'
      fill_in 'user_name', :with => "New Name"
      click_button 'Save details'
    end
    it { should have_content 'Saved' }
    it { should have_content "New Name" }
  end

  describe "change_password" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      click_link 'Change your password'
      fill_in 'user_existing_password', :with => user.password
      fill_in 'user_password', :with => 'new_password'
      fill_in 'user_password_confirmation', :with => 'new_password'
      click_button 'Change password'
    end
    it { should have_content 'Saved' }
    context 'sign out' do
      before do
        sign_out
      end
      it { should have_content "You have been logged out." }
      context "sign in with old password" do
        before do
          sign_in user
        end
        it { should have_content "Password not correct" }
      end
      context 'sign in with new password' do
        before do
          sign_in user, 'new_password'
        end
        it { should have_content "You have been logged in." }
      end
    end
  end

  describe "index" do
    let(:users) { (1..3).map { FactoryGirl.create(:user) } }
    before do
      visit user_path(users[0])
    end
    context "administrator" do
      let(:admin) { FactoryGirl.create(:user, :administrator => true) }
      before do
        sign_in admin
        visit users_path
      end
      it { users.each { |u| page.should have_content u.name } }
    end
    context "regular user" do
      before do
        sign_in users[0]
        visit users_path
      end
      it { should show_404 }
      it { users.each { |u| page.should have_no_content u.name } }
    end
  end

  describe "escape" do
    let(:user) { FactoryGirl.create(:user, :name => bad_script, :affiliation => bad_script) }
    it "should properly escape" do
      visit user_path(:action => 'show', :id => user.id)
      page.should  have_no_xpath("//b", :text => "I got you")
    end
  end

  describe "recently_viewed_talks" do
    let(:talk) { FactoryGirl.create(:talk) }
    subject { page }
    before do
      sign_in user
      visit talk_path(talk)
      visit recently_viewed_talks_path
    end
    it { should have_content talk.title }
  end
end
