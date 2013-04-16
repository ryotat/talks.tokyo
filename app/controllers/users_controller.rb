# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :ensure_user_is_logged_in, :except => %w( new show create password_sent )
  before_filter :find_user, :except => %w( index new create password_sent )
  before_filter :check_can_edit_user, :except => %w( new show create password_sent show index )
  
  # Filters
  
  # Actions
  def new
    @user = User.new
  end

  def index
    only_admin { @users = User.order("id DESC") }
  end
    
  def show
    @show_message = session['return_to'] ? true : false
  end
  
  def edit
    @show_message = session['return_to'] ? true : false
  end
  
  def create
    @user = User.new(params[:user])
    
    if verify_recaptcha(:model => @user, :message => 'reCAPTCHA failed') &&  @user.save
      flash[:confirm] = 'A new account has been created.'
      session[:user_id ] = @user.id
      post_login_actions
    else
      render :action => 'new'
    end
  end
  
  def update    
    if @user.update_attributes(params[:user])
      flash[:confirm] = 'Saved.'
      redirect_to user_url(:id => @user.id)
    else
      if params[:user][:password] # Then we must be trying to change the password and have failed
        render :action => 'change_password'
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    if User.current.administrator?
      redirect_to users_path
    else
      do_logout
      redirect_to home_path
    end
  end

  private
  include CommonUserMethods

  def find_user
    @user = User.find params[:id]
  end

  def check_can_edit_user
    return true if @user.editable?
    flash[:error] = "You do not have permission to edit ‘#{@user.name}}’"
    render :text => "Permission denied", :status => 401
    false
  end
  

end

