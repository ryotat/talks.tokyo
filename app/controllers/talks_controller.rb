# -*- coding: utf-8 -*-
class TalksController < ApplicationController
  before_filter :ensure_user_is_logged_in, :except => %w( show index vcal help )
    
    def login_message
      "You need to be logged in to create or edit a talk."
    end
    
    # Methods for viewing talks
    
    def show
      return page404 unless find_talk
      if User.current
        User.current.just_seen(@talk)
      end
      case params[:format]
        when 'txt'
        render :action => 'text', :formats => [:text], :layout => false
        when 'ics'
        vcal
        when 'json'
        render json: @talk
        else
        set_cal_path
        render :layout => 'with_related'
      end
    end
    
    def vcal
      return page404 unless find_talk
    	headers["Content-Type"] = "text/calendar; charset=utf-8"
    	render :text => [@talk].to_ics
    end
    
    # Creating a talk
    def new
      create_talk
      set_usual_details
      return page403 unless user_can_edit_talk?
      @list = @talk.series
      set_cal_path
      render :action => 'edit'
    end
    
    def create
      @talk = Talk.new(params[:talk])
      return page403 unless user_can_edit_talk?
      if @talk.save
        flash[:confirm] = "Talk ‘#{@talk.name}’ has been created."
        redirect_to talk_url(:id => @talk.id)
      else
        flash[:error] = "Sorry, there were problems creating ‘#{@talk.name}’."
        render :action => 'edit'
      end
    end
    
    # Canceling a talk
    def delete
      return page404 unless find_talk
      return page403 unless user_can_edit_talk?
      
      # Just fall through to the delete view, to get confirmation
      render :layout => false
    end

    def destroy
      return page404 unless find_talk
      return page403 unless user_can_edit_talk?
      @talk.destroy
      respond_to do |format|
        format.html { redirect_to list_path(@talk.series) }
        format.json { head :no_content }
      end
    end

    # Canceling a talk
    def cancel
      return page404 unless find_talk
      return page403 unless user_can_edit_talk?

      series = @talk.series
      @talk.sort_of_delete
      @talk.save
      @response = {:confirm => "Talk ‘#{@talk.name}’ has been canceled."}
      render :template => 'talks/special_messages/update', :formats => [:js]
    end

    # Editing a talk
    def edit
      return false unless ensure_user_is_logged_in
      return page404 unless find_talk
      return page403 unless user_can_edit_talk? 
      set_usual_details
      @list = @talk.series
      set_cal_path
    end
    
    def update
      return false unless ensure_user_is_logged_in
      # The following is to catch "redirect after login" GET requests
      # which can't possibly work due to having not stored the original POST data
      @talk = Talk.new unless find_talk
      return page403 unless user_can_edit_talk?       
      @talk.attributes = params[:talk]
      respond_to do |format|
        if @talk.save
          flash[:confirm] = "Talk ‘#{@talk.name}’ has been saved."
          format.html { redirect_to talk_url(:id => @talk.id) }
          format.xml  { head :ok, :location => talk_url(:id => @talk.id)}
        else
          format.html { render :action => 'edit' }
          format.xml  { render :xml => @talk.errors.to_xml }
        end
      end
    end

    # Helper methods for ajax requests
    
    def help
      @list = List.find params[:list_id]
      @usual_details = UsualDetails.new @list
      @prefix = params[:prefix] || 'talk_'
      render :partial => "help_#{params[:field]}"
    end
    
    def venue_list
      return render(:nothing => true ) unless params[:search] && params[:search].size > 2
      search_term = params[:search].downcase
      @venues = Venue.find(:all, :conditions => [ 'LOWER(name) LIKE ?',"%#{search_term}%"], :order => 'name ASC', :limit => 20)
      @prefix = params[:prefix] || 'talk_'
      render :partial => 'venue', :collection => @venues
    end
    
    def speaker_email_list
      return render(:nothing => true ) unless params[:search] && params[:search].size > 2
      search_term = params[:search].downcase
      @users = User.find(:all, :conditions => [ 'LOWER(email) LIKE ?',"%#{search_term}%"], :order => 'name ASC', :limit => 20)
      @prefix = params[:prefix] || 'talk_'
      render :partial => 'user', :collection => @users
    end
    
    def speaker_name_list
      return render(:nothing => true ) unless params[:search] && params[:search].size > 2
      search_term = params[:search].downcase
      @users = User.find(:all, :conditions => [ 'LOWER(name) LIKE ?',"%#{search_term}%"], :order => 'name ASC', :limit => 20)
      @prefix = params[:prefix] || 'talk_'
      render :partial => 'user', :collection => @users
    end
    
    # Filters
    
    private
    
    def find_talk
      return nil unless params[:id]
      begin
        @talk = Talk.find params[:id]
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end
    
    def create_talk
      @usual_details = UsualDetails.new( List.find( params[:list_id] ) )
      @talk = @usual_details.default_talk
    end

    def set_cal_path
      if ['new','edit'].include? params[:action]
        @cal_path = list_path(:id => @talk.series.id, :period => 'upcoming', :date => @talk.start_time.strftime('%Y/%m/%d'), :target => 'input#talk_date_string', :format => 'calendar_with_talks', :trigger =>'hover')
      else
        @cal_path = list_path(:id => @talk.series.id, :date => @talk.start_time.strftime('%Y/%m/%d'), :target => '#talks-calendar', :format => 'calendar_with_talks', :trigger =>'click')
      end
    end
    include CommonTalkMethods

end
