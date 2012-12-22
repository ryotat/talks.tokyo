require 'spec_helper'
describe Mailer do
  let(:user) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list) }
  let(:subscription) { FactoryGirl.create(:email_subscription, :user_id => user.id, :list_id =>list.id) }
  before do
    add_random_talks(list)
  end
  describe "weekly_list" do
    before do
      subscription.save!
      Mailer.send_weekly_list
    end
    it "should look OK" do
      last_email.to.should include user.email
      last_email.subject.should include "This week's talks"
      last_email.body.should include "If you have any questions please contact"
      last_email.body.should_not include "webmaster@talks.cam.ac.uk"
    end
    it "should include this week's talks" do
      list.talks.select{ |x| x.start_time >  beginning_of_day && x.start_time < beginning_of_day + 1.week }.map do |talk|
        last_email.body.should include talk.title.upcase
      end
    end
    it "should not include earlier talks" do
      list.talks.select{ |x| x.start_time < beginning_of_day}.map do |talk|
        last_email.body.should_not include talk.title.upcase
      end
    end
    it "should not include talks fater today" do 
      list.talks.select{ |x| x.start_time > beginning_of_day + 1.week}.map do |talk|
        last_email.body.should_not include talk.title.upcase
      end
    end
  end

  describe "daily_list" do
    before do
      subscription.save!
      Mailer.send_daily_list
    end
    it "should look OK" do
      last_email.to.should include user.email
      last_email.subject.should include "Today's talks"
      last_email.body.should include "If you have any questions please contact"
      last_email.body.should_not include "webmaster@talks.cam.ac.uk"
    end

    it "should include today's talks" do
      list.talks.select{ |x| x.start_time >  beginning_of_day && x.start_time <  beginning_of_day + 1.day }.map do |talk|
        last_email.body.should include talk.title.upcase
      end
    end
    it "should not include earlier talks" do
      list.talks.select{ |x| x.start_time < beginning_of_day}.map do |talk|
        last_email.body.should_not include talk.title.upcase
      end
    end
    it "should not include talks after today" do
      list.talks.select{ |x| x.start_time > beginning_of_day + 1.day}.map do |talk|
        last_email.body.should_not include talk.title.upcase
      end
    end
  end
end
