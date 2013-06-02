# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Reminders", :js => true do
  let(:list) { FactoryGirl.create(:list) }
  let(:user) { FactoryGirl.create(:user) }
  subject { page }
  before do
    visit list_path(list)
  end
  it { should have_xpath("//a[@href='#{reminder_path(:action => 'new_user', :list => list)}'][@class='btn']") }
  context "new_user" do
    before do
      click_link "メールで購読する"
    end
    it { should have_content "このリストに属するセミナーが開催される場合、開催週のはじめと開催日にリマインダーをお送りします。" }
    context "existing user" do
      before do
        fill_in 'user_email', :with => user.email
        click_button "Subscribe to this list"
      end
      it { should have_content "address is already registered on the system" }
    end
    context "valid user" do
      before do
        fill_in 'user_email', :with => "a@a.jp"
        click_button "Subscribe to this list"
        wait_until { page.has_content? "メールでの購読が設定されました．アカウントに関する情報を指定のメールアドレスに送信しました．" }
      end
      it do
        last_email.to.should include "a@a.jp"
        last_email.subject.should == "Your #{SITE_NAME} password"
      end
    end
  end
end
