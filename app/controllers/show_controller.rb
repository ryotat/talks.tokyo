class ShowController < ApplicationController
  
  # We do this to avoid creating numerous sessions for rss
  # feed requests, xml requests, e-mail requests etc.
  # session :off, :if => Proc.new { |request| request.parameters[:layout] }
  
  layout :decode_layout
  before_filter :decode_div_embed
  before_filter :decode_grouping
  before_filter :decode_logo
  before_filter :decode_finder_params, :except => [:recently_viewed]
  before_filter :find_talks, :except => [:recently_viewed]
  before_filter :decode_list, :except => [:recently_viewed]
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
      if @list
        render :json => @list.as_json.merge({:talks => @talks}).to_json
      else
        render :json => @talks
      end
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

  def decode_finder_params
    @finder = TalkFinder.new(params)
    @errors = @finder.errors
    if params[:starred] && params[:starred]=='1'
      @finder.listed_in(User.current.lists.first.id)
    end
    start_and_end_time_from_params
  end

  def find_talks
    @talks = @finder.find
  end

  def decode_list
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
      year =  params[:today][0,4].to_i
      month = params[:today][4,2].to_i
      day   = params[:today][6,2].to_i
      @today = Time.zone.local(year, month, day)
    else
      @today = Time.zone.now.at_beginning_of_day
    end
    @period = params[:period] || [nil,'list'].include?(params[:format]) &&  (@finder.find.where('start_time >= ?', @today).empty? ?  'archive' : 'upcoming')
    logger.debug "period=#{@period}"
    case @period
    when 'day'
      @finder.start_time = @today
      @finder.end_time   = @today + 1.day
      @finder.ascending  = true unless params[:ascending]
    when 'week'
      @finder.start_time = @today
      @finder.end_time   = @today + 1.week
      @finder.ascending  = true unless params[:ascending]
    when 'upcoming'
      @finder.start_time = @today unless params[:start_time]
      @finder.ascending  = true unless params[:ascending]
    when 'archive'
      @finder.end_time   = @today unless params[:end_time]
      @finder.ascending  = false unless params[:ascending]
    when 'starred'
      @finder.start_time = @today
      @finder.ascending  = true unless params[:ascending]
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
