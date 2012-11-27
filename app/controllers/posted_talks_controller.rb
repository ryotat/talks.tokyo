class PostedTalksController < ApplicationController
  before_filter :ensure_user_is_logged_in, :except => %w( new )
  # GET /posted_talks
  # GET /posted_talks.json
  def index
    @posted_talks = PostedTalk.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posted_talks }
    end
  end

  # GET /posted_talks/1
  # GET /posted_talks/1.json
  def show
    @talk = PostedTalk.find(params[:id])
    return false unless user_can_edit_talk?

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @talk }
    end
  end

  # GET /posted_talks/new
  # GET /posted_talks/new.json
  def new
    unless List.find(params[:list_id]).authenticate_talk_post_password(params[:key])
      return_404
      return false
    end
    @usual_details = UsualDetails.new( List.find( params[:list_id] ) )
    @talk = @usual_details.default_talk(PostedTalk)

    respond_to do |format|
      format.html { render :action => 'edit' }
    end
  end

  # GET /posted_talks/1/edit
  def edit
    return false unless ensure_user_is_logged_in
    @talk = PostedTalk.find(params[:id])
    return false unless user_can_edit_talk?
    set_usual_details
  end

  # POST /posted_talks
  # POST /posted_talks.json
  def create
    @posted_talk = PostedTalk.new(params[:posted_talk])

    respond_to do |format|
      if @posted_talk.save
        format.html { redirect_to @posted_talk, notice: 'Posted talk was successfully created.' }
        format.json { render json: @posted_talk, status: :created, location: @posted_talk }
      else
        format.html { render action: "new" }
        format.json { render json: @posted_talk.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posted_talks/1
  # PUT /posted_talks/1.json
  def update
    return false unless ensure_user_is_logged_in
    @talk = PostedTalk.find(params[:id])
    return false unless user_can_edit_talk?
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

  # DELETE /posted_talks/1
  # DELETE /posted_talks/1.json
  def destroy
    @talk = PostedTalk.find(params[:id])
    return false unless user_can_edit_talk?

    @talk.destroy

    respond_to do |format|
      format.html { redirect_to posted_talks_url }
      format.json { head :no_content }
    end
  end

  include CommonTalkMethods
end
