require 'spec_helper'
describe Mailer do
  let(:list) { FactoryGirl.create(:list) }
  let(:subscription) { FactoryGirl.create(:email_subscription, :list_id =>list.id) }
  describe "weekly_list" do
    it "should create an email with valid body" do
      mail=Mailer.weekly_list(subscription)
      mail.body.raw_source.should include "If you have any questions please contact"
      mail.body.raw_source.should_not include "webmaster@talks.cam.ac.uk"
    end
    it "should send" do
      subscription.save!
      Mailer.send_weekly_list
      albert = find_or_create(User, :albert)
      last_email.to.should include albert.email
      last_email.subject.should include "This week's talks"
      list.talks.select{ |x| x.start_time >  beginning_of_day && x.start_time < beginning_of_day + 1.week }.map do |talk|
        last_email.body.should include talk.title.upcase
      end
      list.talks.select{ |x| x.start_time < beginning_of_day}.map do |talk|
        last_email.body.should_not include talk.title.upcase
      end
      list.talks.select{ |x| x.start_time > beginning_of_day + 1.week}.map do |talk|
        last_email.body.should_not include talk.title.upcase
      end
    end
  end

  describe "daily_list" do
    it "should create an email with valid body" do
      mail=Mailer.daily_list(subscription)
      mail.body.raw_source.should include "If you have any questions please contact"
      mail.body.raw_source.should_not include "webmaster@talks.cam.ac.uk"
    end
    it "should send" do
      subscription.save!
      Mailer.send_daily_list
      albert = find_or_create(User, :albert)
      last_email.to.should include albert.email
      last_email.subject.should include "Today's talks"
      list.talks.select{ |x| x.start_time >  beginning_of_day && x.start_time <  beginning_of_day + 1.day }.map do |talk|
        last_email.body.should include talk.title.upcase
      end
      list.talks.select{ |x| x.start_time < beginning_of_day}.map do |talk|
        last_email.body.should_not include talk.title.upcase
      end
      list.talks.select{ |x| x.start_time > beginning_of_day + 1.day}.map do |talk|
        last_email.body.should_not include talk.title.upcase
      end
    end
  end
end
