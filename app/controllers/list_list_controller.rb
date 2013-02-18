# -*- coding: utf-8 -*-
class ListListController < ApplicationController
  before_filter :ensure_user_is_logged_in
  
  def edit
    @list = List.find(params[:list_id])
    return permission_denied unless @list.editable?
    @list_lists = @list.list_lists.direct
  end
    
  def create
    @child = List.find(params[:child])
    @lists = user.lists
    if params[:add_to_list]
      add_to_multiple_lists
      render :partial => 'lists'
    elsif user.only_personal_list?
      add_to_personal_list
      render :json => @response
    else
      render :layout => false
    end
  end
  
  def destroy
    if params[:id]
      @list_list = ListList.find(params[:id])
      return permission_denied unless @list_list.editable?
      @list_list.destroy
      if params[:return_to_edit] == '1'
        redirect_to include_list_url(:action => 'edit', :list_id => @list_list.list.id)
      else
        redirect_to list_url(:id => @list_list.child_id )
      end
    elsif params[:child]
      if user.only_personal_list?
        remove_from_personal_list
      else
        # redirect_to include_list_url(:action => 'create', :child => params[:child])
      end
      render :json => @response
    end
  end
  
  private
  
  def add_to_personal_list
    @response ={ }
    begin
      unless user.personal_list.children.direct.include?(@child)
        user.personal_list.add @child
        @response[:confirm] = "Added ‘#{@child.name}’ to your personal list"
      end
    rescue CannotAddList => error
      @response[:error] = error.message
    end
  end
  
  def remove_from_personal_list
    @child = List.find(params[:child])
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
          next if list.children.direct.include?(@child) # Don't repeat
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
        next unless list.children.direct.include?(@child)
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
    
end
