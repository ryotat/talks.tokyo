class ShowController < ApplicationController
  
  # We do this to avoid creating numerous sessions for rss
  # feed requests, xml requests, e-mail requests etc.
  # session :off, :if => Proc.new { |request| request.parameters[:layout] }
  
  layout :decode_layout
  before_filter :decode_div_embed
  before_filter :decode_grouping
  before_filter :decode_logo
  before_filter :decode_time_period, :except => [:recently_viewed]
  before_filter :decode_list_details

  def index
    unless ['rss','ics','email'].include?(params[:format]) || check_personal
      return false
    end
    case params[:format]
      when 'list'
      set_cal_path if params[:layout].nil?
      render :action => 'list'
      when 'all'
      render :partial => 'all'
      when 'xml'
      render :action => 'xml', :formats => [:xml], :layout => false
      when 'rss'
      render :action => 'rss', :formats => [:xml], :layout => false
      when 'ics'
      render :text => @talks.to_ics
      when 'txt'
      render :action => 'text', :formats => [:text], :layout => false
      when 'email'
      render :action => 'email', :formats => [:text], :layout => false
      when 'json'
      render json: @talks
      when 'calendar_with_talks'
      @target = params[:target]
      @trigger = params[:trigger]
      @date = params[:date]
      render :action => 'calendar_with_talks', :formats => [:js]
      else
      set_cal_path
      render :action => params[:format]
    end
  end

  # GET /show/stared
  def stared
    finder = TalkFinder.new(:start_time => @start_time, :reverse_order => true)
    @talks = User.current.lists.first.talks.find_public(:all, finder.to_find_parameters)
    respond_to do |format|
      format.html { render :action => 'list' }
      format.json { render json: @talks }
    end
  end

  def recently_viewed
    @talks = User.current.recently_viewed_talks
    respond_to do |format|
      format.html { render :action => 'list', :layout => 'application' }
      format.json { render json: @talks }
    end
  end

  private

  def decode_layout
    params[:layout] || 'with_related'
  end

  def decode_div_embed
    @div_embed = params[:divid] || 'talks'
  end
  
  def decode_grouping
    @groupby = params[:groupby]
  end

  def decode_logo
    @logo = !params[:nologo]
  end

  def decode_time_period
    @finder = TalkFinder.new(params)
    start_and_end_time_from_params
    @errors = @finder.errors
    logger.debug "finder=#{@finder.to_find_parameters}"
    if params[:stared] && params[:stared]=='1'
      @finder.listed_in(User.current.lists.first.id)
    end
    @talks = @finder.find
    unless params[:id]=='all'
      @list = List.find params[:id]
    end
  end
  
  # FIXME: Refactor so that can set this from url
  def decode_list_details
    @list_details = true
    true # Must return true for method to continue
  end	

  def start_and_end_time_from_params
    if params[:today] && params[:today].length == 8
      year =  params[:today][0,4]
      month = params[:today][4,2]
      day   = params[:today][6,2]
      @today = Time.local(year, month, day)
    else
      @today = Time.now.at_beginning_of_day
    end
    case params[:period]
    when 'day'
      @finder.start_time = @today
      @finder.end_time   = @today + 1.day
      @finder.ascending  = true
    when 'week'
      @finder.start_time = @today
      @finder.end_time   = @today + 1.week
      @finder.ascending  = true
    when 'upcoming', 'all'
      @finder.start_time = @today
      @finder.ascending  = true
    when 'archive'
      @finder.end_time   = @today
      @finder.ascending  = false
    when 'stared'
      @finder.start_time = @today
      @finder.ascending  = true
      @finder.listed_in(User.current.lists.first)
    end
  end

  def set_cal_path
    @cal_path = list_path(:id => @list.id, :target => '#talks-calendar', :format => 'calendar_with_talks', :trigger =>'click', :date => @today.strftime('%Y/%m/%d'))
  end

  def check_personal
    if @list && @list.personal? && (!User.current || @list.managers[0] != User.current)
      logger.debug "In check_personal: this list is personal"
      page404
    else
      logger.debug "In check_personal: this list is not personal"
      return true
    end
  end
end
