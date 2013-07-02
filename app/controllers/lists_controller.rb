# -*- coding: utf-8 -*-
class ListsController < ApplicationController
  
  before_filter :ensure_user_is_logged_in, :except =>  %w{ index }
  before_filter :find_list, :except => %w{ new create choose }
  before_filter :check_can_edit_list, :except => %w{ index new create choose details }
  
  def new
    @list = List.new
    @list.ex_directory = false
    respond_to do |format|
      format.html { render :action => 'edit_details' }
    end
  end
  
  def create
    @list = List.new params[:list]
    if @list.save
      @list.users << User.current
      flash[:confirm] = "Successfully created  ‘#{@list.name}’"
      if request.xhr?
        # render lists via js
        @updateurl = params[:updateurl]
        render :format => :js
      else
        redirect_to list_url(:id => @list.id)
      end
    else
      render :action => 'edit_details'
    end
  end
  
  # Other views include edit and edit_details
  
  def update
    if @list.update_attributes( params[:list] )
      flash[:confirm] = 'Details updated.'
      redirect_to list_path(@list)
    else
      render :action => 'edit_details'
    end
  end
  
  # Delete this list
  def destroy
    @list.sort_of_delete
    @list.save
    flash[:confirm] = "List ‘#{@list.name}’ has been deleted."
    if User.current.personal_list
      redirect_to list_url(:id => User.current.personal_list.id )
    else
      redirect_to home_url
    end
  end

  def show_talk_post_url
    @list.randomize_talk_post_password if @list.talk_post_password.nil? || @list.talk_post_password.empty?
    @url = new_posted_talk_url(:list_id => @list.id, :key => @list.talk_post_password)
    @generate_path = generate_talk_post_url_list_path(@list,  :format => 'js')
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def generate_talk_post_url
    @list.randomize_talk_post_password
    @url = new_posted_talk_url(:list_id => @list.id, :key => @list.talk_post_password)
    respond_to do |format|
      format.js
    end
  end
  
  # Still left over. Need to refactor this elsewhere
  
  def choose
    @lists = User.current.lists
    if request.xhr?
      render :partial => 'lists'
    end
  end
    
  private
  
  # Filters
  
  def find_list
    @list = List.find params[:id]
  end
  
  def check_can_edit_list
    return true if @list.editable?
    render :text => "Permission denied", :status => 401
    false
  end
  
end
