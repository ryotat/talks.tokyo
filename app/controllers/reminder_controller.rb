class ReminderController < ApplicationController
  
  before_filter :ensure_user_is_logged_in, :except => [:new_user, :create_user_and_subscription]

  def index
    @user = User.current
    @subscriptions = @user.email_subscriptions
  end
  
  def create
    EmailSubscription.create :list_id => params[:list], :user => User.current 
    if request.xhr?
      @list = List.find(params[:list])
      @response = {:confirm => I18n.t("reminder.confirm.subscribe") }
      render :action => 'update', :format => :js
    else
      redirect_to reminder_url
    end
  end
  
  def destroy
    find_subscription
    return false unless user_can_edit_subscription?
    @subscription.destroy
    if request.xhr?
      @list = @subscription.list
      @response ={ :confirm => I18n.t("reminder.confirm.unsubscribe") }
      render :action => 'update', :format => :js
    else
      redirect_to reminder_url
    end
  end

  def new_user
    @list = params[:list]
    render :layout => false
  end

  def create_user_and_subscription
    @user = User.new(params[:user])
    if verify_recaptcha(:model => @user, :message => 'reCAPTCHA failed')
      begin
        password = @user.randomize_password
        Mailer.password(@user, password).deliver
        EmailSubscription.create :list_id => params[:list], :user => @user 
        @response = {:confirm => I18n.t('reminder.confirm.create_user') }
      rescue ActiveRecord::RecordInvalid
        @response = {:error => to_list(@user.errors) }
      end
    else
      @response = {:error => to_list(@user.errors) }
    end
    render :action => 'update_flash', :format => :js
  end

  private
  
  def find_subscription
    @subscription = EmailSubscription.find(params[:id])
  end
  
  def user_can_edit_subscription?
    return true if @subscription.editable?
    render :text => "Permission denied", :status => 401
    false
  end

  include ErrorMessages
end
