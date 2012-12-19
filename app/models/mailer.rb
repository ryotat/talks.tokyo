class Mailer < ActionMailer::Base
  
  include Rails.application.routes.url_helpers
  default_url_options[:host] = HOST ||= "localhost:3000"
  
  # FIXME: Refactor into class variables and set in environment.rb
  FROM = "noreply@#{HOST.gsub(/:.*$/,'')}"

  
  # The periodic mailshots
  
  def self.send_mailshots
    send_weekly_list if Time.now.wday == 0
    send_daily_list
  end
  
  def self.send_weekly_list
    EmailSubscription.find(:all).each do |subscription|
      mail = weekly_list( subscription )
      if mail.body =~ /\(No talks\)/
        logger.info "No talks, so not sending message"
      else
        mail.deliver
      end
    end
  end
  
  def self.send_daily_list
    EmailSubscription.find(:all).each do |subscription|
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
    @subject    = 'Giving a talk in Cambridge'
    @body       = { :user => user, :url => talk_url(:id => talk.id, :action => 'edit'), :talk => talk }
    @recipients = user.email
    @cc         = talk.organiser.email if talk.organiser && talk.organiser.email
    @from       = FROM
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def daily_list( subscription )
    logger.info "Creating daily message about #{subscription.list.name} for #{subscription.user.email}"
    set_common_variables( subscription )
    parameters = { :template => 'show/email', :id => subscription.list.id, :seconds_after_today => 1.day, :seconds_before_today => 0  }
    @text = get_list( parameters )
    mail(
         :to => subscription.user.email,
         :from => FROM,
         :subject => "[#{SITE_NAME}] Today's talks: #{subscription.list.name}",
         :body => render_to_string(:action=>"daily_list", :formats => [:text]))  end
  
  def weekly_list( subscription )
    logger.info "Creating weekly message about #{subscription.list.name} for #{subscription.user.email}"
    set_common_variables( subscription )
    parameters = { :template => 'show/email', :id => subscription.list.id,:seconds_after_today => 1.week,:seconds_before_today => 0 }
    @text = get_list( parameters )
    mail(
         :to => subscription.user.email,
         :from => FROM,
         :subject => "[#{SITE_NAME}] This week's talks: #{subscription.list.name}",
         :body => render_to_string(:action=>"weekly_list", :formats => [:text]))
  end
  
  def talk_tickle( tickle )
    talk = tickle.about
    @tickle = tickle
    @talk = talk
    @talk_url = talk_url(:id => talk.id)
    @talk_ics_url = talk_url(:id => talk.id, :action => 'vcal' )
    @add_to_list_url = include_talk_url({:action => 'create'}, :child => talk)
    mail(
	:to => tickle.recipient_email,
	:cc => tickle.sender_email,
	:from => FROM,
	:subject => "[#{SITE_NAME}] A talk that you might be interested in")
  end
  
  def list_tickle( tickle )
    @tickle = tickle
    @list = tickle.about
    @talks = @list.talks.find(:all, :limit => 5, :order => 'start_time ASC', :conditions => ['start_time > ?', Time.now.at_beginning_of_day ])
    @list_url = list_url(:id => @list.id)
    @list_webcal_url = list_url(:id => @list.id, :action => 'ics', :only_path => false, :protocol => 'webcal' )
    @add_to_list_url = include_list_url({:action => 'create'}, :child => @list.id)
    mail(
         :to => tickle.recipient_email,
         :cc => tickle.sender_email,
         :from => FROM,
         :subject => "[#{SITE_NAME}] A list that you might be interested in")
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
  
  def set_common_variables( subscription )
    @user = subscription.user
    @host = HOST
    @recipients = 
    @from       = FROM
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def get_list( options )
    @list = List.find options[:id]
    finder = TalkFinder.new(options)
    @errors = finder.errors
    @talks = @list.talks.find( :all, finder.to_find_parameters)
    render_to_string( options )
  end
end
