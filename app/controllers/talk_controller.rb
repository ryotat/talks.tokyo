Mime::Type.register "text/plain", :txt

class TalkController < ApplicationController
    skip_before_filter :verify_authenticity_token, :only => [:help, :venue_list, :speaker_name_list, :speaker_email_list]
    before_filter :ensure_user_is_logged_in, :except => %w( show index vcal help )
    
    def login_message
      "You need to be logged in to create or edit a talk."
    end
    
    # Methods for viewing talks
    
    def index
      return page404 unless find_talk
      respond_to do |format|
        format.html { render :layout => 'with_related' }
        format.txt { render :action => 'text', :formats => [:text], :layout => false }
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
      render :action => 'edit'
    end
    
    def create
      @talk = Talk.new(params[:talk])
      return page403 unless user_can_edit_talk?
      if @talk.save
        flash[:confirm] = "Talk &#145;#{@talk.name}&#146; has been created"
        redirect_to talk_url(:id => @talk.id)
      else
        flash[:error] = "Sorry, there were problems creating &#145;#{@talk.name}&#146;."
        render :action => 'edit'
      end
    end
    
    # Deleting a talk
    def delete
      return page404 unless find_talk
      return false unless ensure_user_is_logged_in
      return page403 unless user_can_edit_talk?
      
      if request.get?
        # Just fall through to the delete view, to get confirmation
      
      elsif request.post?
        series = @talk.series
        @talk.sort_of_delete
        @talk.save
        flash[:confirm] = "Talk &#145;#{@talk.name}&#146; has been deleted."
        redirect_to list_url(:id => series.id)
      end
    end
            
    # Editing a talk
    
    def edit
      return false unless ensure_user_is_logged_in
      return page404 unless find_talk
      return page403 unless user_can_edit_talk? 
      set_usual_details
      @list = @talk.series
    end
    
    def update
      return false unless ensure_user_is_logged_in
      # The following is to catch "redirect after login" GET requests
      # which can't possibly work due to having not stored the original POST data
      if !request.post?
        respond_to do |format|
          flash[:warning] = "Sorry, your talk was not saved, please try again."
          format.html { redirect_to list_details_url(:action => 'choose') }
        end
	return true
      end
      @talk = Talk.new unless find_talk
      @talk.attributes = params[:talk]
      return page403 unless user_can_edit_talk?       
      respond_to do |format|
        if @talk.save
          flash[:confirm] = "Talk &#145;#{@talk.name}&#146; has been saved."
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
      @talk.ex_directory = false
    end

    include CommonTalkMethods

end
