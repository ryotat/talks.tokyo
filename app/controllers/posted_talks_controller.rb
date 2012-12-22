class PostedTalksController < ApplicationController
  before_filter :ensure_user_is_logged_in, :except => %w( new create )
  # GET /posted_talks
  # GET /posted_talks.json
  def index
    if User.current.administrator?
      @posted_talks = PostedTalk.all
    else
      return page404 unless params[:list_id]
      return page403 unless user_can_approve? List.find(params[:list_id])
      @posted_talks = PostedTalk.find(:all, :conditions => {:series_id => params[:list_id]})
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posted_talks }
    end
  end

  # GET /posted_talks/1
  # GET /posted_talks/1.json
  def show
    @talk = PostedTalk.find(params[:id])
    return page403 unless user_can_edit_talk?

    respond_to do |format|
      format.html { render :layout => 'with_related' } # show.html.erb
      format.json { render json: @talk }
    end
  end

  # GET /posted_talks/new
  # GET /posted_talks/new.json
  def new
    return page404 unless params[:list_id]
    return page403 unless List.find(params[:list_id]).authenticate_talk_post_password(params[:key])
    @usual_details = UsualDetails.new( List.find( params[:list_id] ) )
    @talk = @usual_details.default_talk(PostedTalk)

    if User.current
      @talk.name_of_speaker = "#{User.current.name} (#{User.current.affiliation})"
      @talk.speaker_email = "#{User.current.email}"
    end
    
    respond_to do |format|
      format.html { render :action => 'edit' }
    end
  end

  # GET /posted_talks/1/edit
  def edit
    return false unless ensure_user_is_logged_in
    @talk = PostedTalk.find(params[:id])
    return page403 unless user_can_edit_talk?
    set_usual_details
  end

  # POST /posted_talks
  # POST /posted_talks.json
  def create
    @talk = PostedTalk.new(params[:posted_talk])
    @talk.sender_ip = request.remote_ip
    respond_to do |format|
      if @talk.save
        @talk.notify_organizers
        flash[:confirm] = "Your talk &#145;#{@talk.title}&#146; has been created. Please wait for one of the organizers to approve your talk."
        format.html { render :action => "show" }
        format.json { render json: @talk, status: :created, location: @talk }
      else
        format.html { render action: "edit" }
        format.json { render json: @talk.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posted_talks/1
  # PUT /posted_talks/1.json
  def update
    return false unless ensure_user_is_logged_in
    @talk = PostedTalk.find(params[:id])
    return page403 unless user_can_edit_talk?
    respond_to do |format|
      if @talk.update_attributes(params[:posted_talk])
        format.html { redirect_to @talk, notice: 'Posted talk was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @talk.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
    @talk = PostedTalk.find(params[:id])
    return page403 unless user_can_edit_talk?
  end

  # DELETE /posted_talks/1
  # DELETE /posted_talks/1.json
  def destroy
    @talk = PostedTalk.find(params[:id])
    return page403 unless user_can_edit_talk?

    @talk.destroy

    respond_to do |format|
      format.html { redirect_to posted_talks_url }
      format.json { head :no_content }
    end
  end

  # GET /posted_talks/1/approve
  def approve
    @talk = PostedTalk.find(params[:id])
    return page403 unless @talk.approvable?
    unless @talk.start_time && @talk.end_time && @talk.venue
      flash[:error] = "Time or venue not fully specified."
      render  :action => 'edit' 
      return false
    end

    t=@talk
    @talk = Talk.new(:title => t.title,
                     :abstract => t.abstract,
                     :start_time=>t.start_time,
                     :end_time=>t.end_time,
                     :name_of_speaker=> t.name_of_speaker,
                     :speaker_email=>t.speaker_email,
                     :series_id=>t.series_id,
                     :venue_id=>t.venue_id,
                     :language=>t.language)
    respond_to do |format|
      if @talk.save
        t.notify_approved(@talk.id)
        t.destroy
        flash[:confirm] = "Talk &#145;#{@talk.name}&#146; has been saved."
        format.html { redirect_to talk_url(:id => @talk.id) }
      else
        format.html { render :action => 'show' }
      end
    end
  end

  include CommonTalkMethods

  private
  def user_can_approve?(list)
    return true if list.users.include? User.current
    false
  end
end
