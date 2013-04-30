require 'bcrypt'
require 'spec_helper'

describe "Logins" do
  subject { page }
  describe "Log in" do
    before { visit login_path }

    describe "Page looks OK" do
      it { should have_selector 'input#email' }
      it { should have_selector 'input#password' }
      it { should have_link 'E-mail me my password', href:login_path(:action => 'lost_password') }
      it { should have_link 'No account?', href:new_user_path }
    end

    describe "New user's login" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
      end
      it "should redirect to the edit page" do 
        current_path.should == edit_user_path(user)
      end
      it { should have_selector 'div.alert-success', :text=>"You have been logged in" }
    end

    describe "Successful login" do
      let(:user) { FactoryGirl.create(:user, :last_login => Time.now) }
      before do
        sign_in user
      end
      it { should have_selector 'div.alert-success', :text=>"You have been logged in" }
      it { should have_link 'Edit your details', href:edit_user_path(user) }
      it { should have_link "#{user.name}'s list", href:list_url(:action => 'index', :id=> user.personal_list) }
    end

    describe "Login+redirect" do
      let(:user) { FactoryGirl.create(:user, :last_login => Time.now) }
      before do
        visit list_path(:action => 'index', :id=> user.personal_list)
        sign_in user
      end
      it "should redirect to the previous page" do 
        current_path.should == list_path(:action => 'index', :id=> user.personal_list)
      end
      it { should have_selector 'div.alert-success', :text=>"You have been logged in" }
    end
    
    describe "Unsuccessful login" do
      let(:user) {FactoryGirl.create(:user) }
      before { sign_in user, "wrong password" }
      it { should have_content 'Password not correct' }
    end

  end

  describe "Lost password" do
    before do
      visit login_path
      click_link "E-mail me my password"
    end
    it "should look OK" do
      page.should have_content 'Your e-mail address'
      page.should have_selector 'input#email'
    end
    
    it "resets and sends new password" do
      user = FactoryGirl.create(:user)
      fill_in "email", with: user.email
      click_button "Send me my password"
      last_email.to.should include(user.email)
      new_password = last_email.body.to_s.split("\n").grep(/^password: [\w0-9]+/)[0].split(" ")[1]
      sign_in user, new_password
      page.should have_link 'Edit your details', href:edit_user_path(user)
      page.should have_link "#{user.name}'s list", href:list_url(:action => 'index', :id=> user.personal_list)
    end
  end
  
  describe "Logout" do
    let(:user) { FactoryGirl.create(:user) }
    subject { page }
    before do
      sign_in user
      click_link "Log out"
    end
    it { should have_selector 'div.alert-success', :text=>"You have been logged out" }
    it { should have_content "You have been logged out" }
    it { should_not have_link 'Edit your details', href:user_url(:action => 'edit', :id => user) }
    context "and login" do
      before do
        click_link "Sign in"
        fill_in "email", with: user.email
        fill_in "password", with: user.password
        click_button "Log in"
      end
      it { current_path.should == list_path(user.personal_list) }
      it { should have_selector 'div.alert-success', :text=>"You have been logged in" }
    end
  end

  describe "new_user" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
    end
    it "should not say talks.cam" do
      visit login_path(:action => 'new_user', :id => user.id)
      page.should_not have_content("talks.cam")
    end
  end
  
  context "suspended account" do
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, :organizer => user) }
    before do
      sign_in user
      user.suspend
      Thread.current[:user]=nil # this should happen automatically
    end
    context "logout should work" do
      before do
        sign_out
      end
      it { should have_content "You have been logged out." }
      context "login" do
        before { sign_in user }
        it { should have_content "Your account is temporarily suspended. Please contact the webmaster." }
      end
    end
    context "try adding a new talk" do
      before do
        visit new_talk_path(:list_id => list)
      end
      it { should have_content "You need to be logged in to create or edit a talk." }
    end
  end

end
