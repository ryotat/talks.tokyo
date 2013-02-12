# -*- coding: utf-8 -*-
class ListTalkController < ApplicationController

  before_filter :ensure_user_is_logged_in
  
  def edit
    @list = List.find(params[:list_id])
    return permission_denied unless @list.editable?
    @list_talks = @list.list_talks.direct
  end
  
  def create
    @child = Talk.find(params[:child])
    @lists = user.lists
    if params[:add_to_list]
      add_to_multiple_lists
    elsif user.only_personal_list?
      add_to_personal_list
    end
  end

  def destroy
    if params[:id]
      @list_talk = ListTalk.find(params[:id])
      return permission_denied unless @list_talk.editable?
      @list_talk.destroy
      if params[:return_to_edit] == '1'
        redirect_to include_talk_url(:action => 'edit', :list_id => @list_talk.list.id)
      else
        redirect_to talk_url(:id => @list_talk.talk_id )
      end
    elsif params[:child]
      if user.only_personal_list?
        remove_from_personal_list
      else
        redirect_to include_list_url(:action => 'create', :child => params[:child])
      end
    end
  end
  
  private
  
  def add_to_personal_list
    unless user.personal_list.talks.direct.include?(@child)
      user.personal_list.add @child
      flash[:confirm] = "Added ‘#{@child.name}’ to your personal list"
    end
    redirect_to talk_url(:id => @child )
  end

  def remove_from_personal_list
    @child = Talk.find(params[:child])
    user.personal_list.remove @child
    flash[:confirm] = "Removed ‘#{@child.name}’ from your personal list"
    redirect_to talk_url(:id => @child )
  end
  
  def add_to_multiple_lists
    flash[:confirm] = "Talk ‘#{@child.name}’: "
    params[:add_to_list].each do |list_id,action| 
      list = List.find(list_id)
      unless list.editable?
        @not_permitted = true
        next
      end
      case action
      when 'add'
          next if list.talks.direct.include?(@child) # Don't repeat
          if list.add @child
            flash[:confirm] << "added to ‘#{list}’, "
          else
            flash[:warning] ||= ""
            flash[:warning] << I18n.t(:cannot_add_to_public)
          end
      when 'remove'
        begin
          next unless list.talks.direct.include?(@child)
          list.remove @child
          flash[:confirm] << "removed from ‘#{list}’, "
        rescue CannotRemoveTalk => error
          flash[:warning] ||= ""
          flash[:warning] << error.message
        end
      end
    end
    if @not_permitted
      permission_denied
    else
      redirect_to talk_url(:id => @child )
    end
  end
  
  def user
    User.current
  end  
  
  def permission_denied
    render :text => "Permission denied", :status => 401
  end
  
end
