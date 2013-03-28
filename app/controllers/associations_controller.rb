# -*- coding: utf-8 -*-
class AssociationsController < ApplicationController
  before_filter :ensure_user_is_logged_in
  
  def edit
    @list = List.find(params[:list_id])
    return permission_denied unless @list.editable?
    @childtype = params[:type]
    find_links
  end

  def new
    find_child
    @lists = user.lists
    @parents = @child.parents
    @updateurls = urls_for_update
    if request.xhr?
      if params[:only_lists]
        render :partial => 'lists'
      else
        render :layout => false
      end
    end
  end

  # POST /talks/:id/associations
  # POST /lists/:id/associations
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
      if params[:add_to_list]
        add_to_multiple_lists
      end
      render :partial => 'lists'
    end
  end

  def destroy
    if params[:id]
      # DELETE /associations/:id
      # DELETe /associations/:id
      find_link
      return permission_denied unless @link.editable?
      @link.destroy
      if request.xhr?
        @list=@link.parent; @childtype=@link.child.class.to_s.downcase
        find_links
        render :partial => 'links'
      else
        redirect_to list_path(:id => @link.child_id )
      end
    elsif params[:list_id] || params[:talk_id]
      # DELETE /talks/:talk_lid/associations
      # DELETE /lists/:list_id/associations
      find_child
      if user.only_personal_list?
        remove_from_personal_list
        render :action => 'update', :format => :js
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
        begin
          list.remove @child
          flash.now[:confirm] ||= "List ‘#{@child.name}’: "
          flash.now[:confirm] << "removed from ‘#{list}’, "
        rescue CannotRemoveTalk => error
          flash.now[:error] ||= ""
          flash.now[:error] << error.message
        end
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
      @child = Talk.find(params[:talk_id])
     when 'list'
      @child = List.find(params[:list_id])
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

  def find_links
    case @childtype
    when 'talk'
      @links = @list.list_talks
    when 'list'
      @links = @list.list_lists
    end
  end

  def urls_for_update
    case params[:type]
    when 'talk'
      {:create => talk_associations_path(@child), :new_list => new_talk_association_path(@child, :only_lists => 1)}
    when 'list'
      {:create => list_associations_path(@child), :new_list => new_list_association_path(@child, :only_lists => 1)}
    end
  end
end
