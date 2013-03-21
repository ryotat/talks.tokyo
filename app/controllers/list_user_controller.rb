class ListUserController < ApplicationController

  before_filter :find_models, :except => %w{ auto_complete_for_user_email }  
  before_filter :ensure_user_is_logged_in, :except => %w{ index auto_complete_for_user_email }
  before_filter :check_can_edit_model, :except => %w{ index auto_complete_for_user_email }
  
  # auto_complete_for :user, :email
  
  def index
    @users = @list.users
  end

  def edit
    @list_users = @list.list_users
    @list_user = ListUser.new(:list => @list)
  end

  def create
    new_user = User.find_by_email(params[:list_user][:user_email])
    if new_user
      @list_user = ListUser.create!(params[:list_user])
      flash.now[:confirm] = "Successfully added #{new_user.name} (#{new_user.email})."
    else
      flash.now[:error] = "User with email #{params[:list_user][:user_email]} does not exist!" 
    end
    @list_users = @list.list_users
    if request.xhr?
      render :partial => 'managers'
    else
      respond_to do |format|
        format.html { redirect_to_edit_page }
      end
    end
  end

  def destroy
    old_user = User.find(@list_user.user_id)
    @list_user.destroy
    flash.now[:confirm] = "Successfully removed #{old_user.name} (#{old_user.email})."
    if request.xhr?
      @list_users = @list.list_users
      render :partial => 'managers'
    end
  end
  
  private
  
  def find_models
    if params[:id]
      @list_user = ListUser.find(params[:id])
      @list = @list_user.list
    else
      @list = List.find(params[:list_id] || params[:list_user][:list_id])
    end
  end
  
  def check_can_edit_model
    logger.debug "list=#{@list.name}"
    logger.debug "user=#{User.current.name}"
    return true if @list.editable?
    render :text => "Permission denied", :status => 401
    false
  end
  
  def redirect_to_edit_page
    redirect_to list_user_url(:action => 'edit', :list_id => @list.id)
  end
end
