require 'spec_helper'

describe "Logins" do
  describe "Log in" do
    before { visit login_path }
    subject { page }
    it { should have_selector 'input#email', 'type:text' }
    it { should have_selector 'input#password' }
    it { should have_link 'E-mail me my password', href:login_path(:action => 'lost_password') }
    it { should have_link 'No account?', href:new_user_path }
  end
end
