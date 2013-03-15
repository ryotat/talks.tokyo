# -*- coding: utf-8 -*-
class RelationsController < ApplicationController
  before_filter :ensure_user_is_logged_in
  
  def edit
    @list = List.find(params[:list_id])
    return permission_denied unless @list.editable?
    case params[:type]
    when 'talk'
      @links = @list.list_talks
    when 'list'
      @links = @list.list_lists
    end
  end

  def new
    find_child
    @lists = user.lists
    @parents = @child.parents
    @updateurl = url_for_update
    if request.xhr?
      render :layout => false
    end
  end

  def create
    find_child
    unless request.xhr?
      redirect_to list_path(@child)
      return false
    end

    if user.only_personal_list?
      add_to_personal_list
      render :action => 'update', :format => :js
    else
      @lists = user.lists
      @parents = @child.parents
      @updateurl = url_for_update
      if params[:add_to_list]
        add_to_multiple_lists
      end
      render :partial => 'lists'
    end
  end
  
  def destroy
    if params[:id]
      find_link
      return permission_denied unless @link.editable?
      @link.destroy
      if params[:return_to_edit] == '1'
        redirect_to include_path(:action => 'edit', :list_id => @link.list.id, :type => params[:type])
      else
        redirect_to list_url(:id => @link.child_id )
      end
    elsif params[:child]
      find_child
      if user.only_personal_list?
        remove_from_personal_list
        render :action => 'update', :format => :js
      else
        redirect_to include_path(:action => 'new', :child => params[:child], :type => params[:type])
      end
    end
  end
  
  private
  
  def add_to_personal_list
    @response ={ }
    begin
      unless @child.parents.include?(user.personal_list)
        user.personal_list.add @child
        @response[:confirm] = "Added ‘#{@child.name}’ to your personal list"
      end
    rescue CannotAddList => error
      @response[:error] = error.message
    end
  end
  
  def remove_from_personal_list
    user.personal_list.remove @child
    @response = {:confirm => "Removed ‘#{@child.name}’ from your personal list"}
  end
  
  def add_to_multiple_lists
    params[:add_to_list].each do |list_id,action| 
      list = List.find(list_id)
      unless list.editable?
        @not_permitted = true
        next
      end
      case action
      when 'add'
        begin
          next if @parents.include?(list) # Don't repeat
          if list.add @child
            flash.now[:confirm] ||= "List ‘#{@child.name}’: "
            flash.now[:confirm] << "added to ‘#{list}’, "
          else
            flash.now[:warning] ||= ""
            flash.now[:warning] << I18n.t(:cannot_add_to_public)
          end
        rescue CannotAddList => error
          flash.now[:warning] ||= ""
          flash.now[:warning] << error.message
        end
      when 'remove'
        next unless @parents.include?(list)
        list.remove @child
        flash.now[:confirm] ||= "List ‘#{@child.name}’: "
        flash.now[:confirm] << "removed from ‘#{list}’, "
      end
    end
    if @not_permitted
      permission_denied
    end
  end
  
  def user
    User.current
  end  
  
  def permission_denied
    render :text => "Permission denied", :status => 401
  end

  private
  def find_child
    case params[:type]
     when 'talk'
      @child = Talk.find(params[:child])
     when 'list'
      @child = List.find(params[:child])
    end
  end

  def find_link
    case params[:type]
    when 'talk'
      @link = ListTalk.find(params[:id])
    when 'list'
      @link = ListList.find(params[:id])
    end
  end

  def url_for_update
    case params[:type]
    when 'talk'
      include_talk_path(:action => 'create', :child => @child.id  )
    when 'list'
      include_list_path(:action => 'create', :child => @child.id  )
    end
  end
end
