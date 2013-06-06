require 'spec_helper'
shared_examples "weekly email" do
  it "should look OK" do
    last_email.to.should include address
    last_email.subject.should include "This week's talks"
    last_email.body.should include "If you have any questions please contact"
    last_email.body.should_not include "webmaster@talks.cam.ac.uk"
  end
  it "should include this week's talks" do
    list.talks.select{ |x| x.start_time >  beginning_of_day && x.start_time < beginning_of_day + 1.week }.map do |talk|
      last_email.body.should include talk.title
      last_email.body.should include I18n.l(Date.parse(talk.start_time.to_s), :format => :long)
    end
  end
  it "should not include earlier talks" do
    list.talks.select{ |x| x.start_time < beginning_of_day}.map do |talk|
      last_email.body.should_not include talk.title
    end
  end
  it "should not include talks after this week" do 
    list.talks.select{ |x| x.start_time > beginning_of_day + 1.week}.map do |talk|
      last_email.body.should_not include talk.title
    end
  end
end

shared_examples "daily email" do
  it "should look OK" do
    last_email.to.should include address
    last_email.subject.should include "Today's talks"
    last_email.body.should include "If you have any questions please contact"
    last_email.body.should_not include "webmaster@talks.cam.ac.uk"
  end

  it "should include today's talks" do
    list.talks.select{ |x| x.start_time >  beginning_of_day && x.start_time <  beginning_of_day + 1.day }.map do |talk|
      last_email.body.should include talk.title
      last_email.body.should include I18n.l(Date.parse(talk.start_time.to_s), :format => :long)
    end
  end
  it "should not include earlier talks" do
    list.talks.select{ |x| x.start_time < beginning_of_day}.map do |talk|
      last_email.body.should_not include talk.title
    end
  end
  it "should not include talks after today" do
    list.talks.select{ |x| x.start_time > beginning_of_day + 1.day}.map do |talk|
      last_email.body.should_not include talk.title
    end
  end
end

describe Mailer do
  let(:user) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list) }
  before do
    add_random_talks(list)
  end
  [:en, :ja].each do |locale|
    context "#{locale}" do
      before do
        user.locale = locale
        user.save
        list.default_language = locale
        list.save
      end        
      describe "weekly_list" do
        let(:subscription) { FactoryGirl.create(:email_subscription, :user_id => user.id, :list_id =>list.id) }
        let(:address) { user.email }
        before do
          subscription.save!
          Mailer.send_weekly_list
        end
        it_behaves_like "weekly email"
      end
      describe "daily_list" do
        let(:subscription) { FactoryGirl.create(:email_subscription, :user_id => user.id, :list_id =>list.id) }
        let(:address) { user.email }
        before do
          subscription.save!
          Mailer.send_daily_list
        end
        it_behaves_like "daily email"
      end

      describe "weekly mailing list" do
        let(:address) { "test@example.com" }
        before do
          list.mailing_list_address = address
          list.save
          Mailer.send_weekly_list
        end
        it_behaves_like "weekly email"
      end

      describe "daiy mailing list" do
        let(:address) { "test@example.com" }
        before do
          list.mailing_list_address = address
          list.save
          Mailer.send_daily_list
        end
        it_behaves_like "daily email"
      end
    end
  end

end
