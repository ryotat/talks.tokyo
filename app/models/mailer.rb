# -*- coding: utf-8 -*-
class Mailer < ActionMailer::Base
  
  include Rails.application.routes.url_helpers
  default_url_options[:host] = HOST ||= "localhost:3000"
  
  # FIXME: Refactor into class variables and set in environment.rb
  FROM = "noreply@#{WEBMASTER.gsub(/.*@/,'')}"

  
  # The periodic mailshots
  
  def self.send_mailshots
    send_weekly_list if Time.now.wday == 0
    send_daily_list
  end
  
  def self.send_weekly_list
    (EmailSubscription.find(:all)+
     List.with_mailing_list_address).each do |subscription|
      mail = weekly_list( subscription )
        if mail.body =~ /\(No talks\)/
        logger.info "No talks, so not sending message"
      else
        mail.deliver
      end
    end
  end
  
  def self.send_daily_list
    (EmailSubscription.find(:all)+
       List.with_mailing_list_address).each do |subscription|
      mail = daily_list( subscription )
      if mail.body =~ /\(No talks\)/
        logger.info "No talks, so not sending message"
      else
        mail.deliver
      end
    end
  end
  
  # The mails
  
  def password(user, newpassword)
    @user = user
    @url  = login_url(:action => 'index')
    @newpassword = newpassword
    mail(
         :to => user.email,
         :from => FROM,
         :subject => "Your #{SITE_NAME} password")
  end
  
  def speaker_invite(user, talk)
    @user = user
    @url  = talk_url(:id => talk.id, :action => 'edit')
    @talk = talk
    mail(
         :to => user.email,
         :from => FROM,
         :cc => (talk.organiser && talk.organiser.email) ? talk.organiser.email : nil,
         :subject => "Your talk #{talk.title} has been updated")
  end
  
  def daily_list( subscription )
    set_common_variables( subscription )
    set_locale
    logger.info "Creating daily message about #{@list.name} for #{@to}"
    parameters = { :template => 'show/email', :id => @list.id, :seconds_after_today => 1.day, :seconds_before_today => 0 }
    @text = get_list( parameters )
    mail(
         :to => @to,
         :from => FROM,
         :subject => "[#{SITE_NAME}] Today's talks: #{@list.name}")
  end
  
  def weekly_list( subscription )
    set_common_variables( subscription )
    set_locale
    logger.info "Creating weekly message about #{@list.name} for #{@to}"
    parameters = { :template => 'show/email', :id => @list.id,:seconds_after_today => 1.week,:seconds_before_today => 0 }
    @text = get_list( parameters )
    mail(
         :to => @to,
         :from => FROM,
         :subject => "[#{SITE_NAME}] This week's talks: #{@list.name}")
  end
  
  def talk_tickle( tickle )
    talk = tickle.about
    @tickle = tickle
    @talk = talk
    @talk_url = talk_url(:id => talk.id)
    @talk_ics_url = talk_url(:id => talk.id, :format => 'ics' )
    @add_to_list_url = new_talk_association_url(talk)
    mail(
	:to => tickle.recipient_email,
	:cc => tickle.sender_email,
	:from => FROM,
	:subject => tickle.subject || "[#{SITE_NAME}] A talk that you might be interested in",
        :body => tickle.body)
  end
  
  def list_tickle( tickle )
    @tickle = tickle
    @list = tickle.about
    @talks = @list.talks.find(:all, :limit => 5, :order => 'start_time ASC', :conditions => ['start_time > ?', Time.now.at_beginning_of_day ])
    @list_url = list_url(:id => @list.id)
    @list_webcal_url = list_url(@list, :format => 'ics', :only_path => false, :protocol => 'webcal' )
    @add_to_list_url = new_list_association_url(@list)
    mail(
         :to => tickle.recipient_email,
         :cc => tickle.sender_email,
         :from => FROM,
         :subject => tickle.subject || "[#{SITE_NAME}] A list that you might be interested in",
         :body => tickle.body)
  end

  def notify_new_posted_talk(user, talk)
    @talk = talk
    @talk_url = posted_talk_url(:id => talk.id)
    @approve_url = approve_posted_talk_url(:id => talk.id)
    @edit_url = edit_posted_talk_url(:id => talk.id)
    @delete_url = delete_posted_talk_url(:id => talk.id)
    mail(
         :to => user.email,
         :from => FROM,
         :subject => "[#{SITE_NAME}] #{talk.speaker.name} posted a new talk for #{talk.series.name} series")
  end

  def notify_talk_approved(talk, id)
    @talk = talk
    @id = id
    mail(
         :to =>talk.speaker.email,
         :cc =>talk.series.users.map {|x| x.email},
         :from => FROM,
         :subject => "[#{SITE_NAME}] #{talk.title} has been approved by one of the organizers")
  end
  
  private

  def set_locale
    if @user
      I18n.locale = @user.locale
    else
      I18n.locale = @list.default_language
    end
    logger.info "locale = #{I18n.locale}"
  end
  
  def set_common_variables( subscription )
    if subscription.instance_of?(EmailSubscription)
      @user = subscription.user
      @to = @user.email
      @list = subscription.list
    else
      # Subscription is a list with mailing list address
      @to = subscription.mailing_list_address
      @list = subscription
    end
    @host = HOST
    @recipients = 
    @from       = FROM
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def get_list( options )
    finder = TalkFinder.new(options)
    @errors = finder.errors
    @talks = @list.talks.find( :all, finder.to_find_parameters)
    render_to_string( options )
  end
  
end
