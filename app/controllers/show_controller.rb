Mime::Type.register "text/plain", :txt
Mime::Type.register "text/plain", :email

class ShowController < ApplicationController
  
  # We do this to avoid creating numerous sessions for rss
  # feed requests, xml requests, e-mail requests etc.
  # session :off, :if => Proc.new { |request| request.parameters[:layout] }
  
  layout :decode_layout
  before_filter :decode_div_embed
  before_filter :decode_time_period, :except => [:day, :week, :stared, :all]
  before_filter :start_time_from_start_date, :only => [:day, :week, :stared, :all]
  before_filter :decode_list_details

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :action => 'xml', :formats => [:xml], :layout => false }
      format.rss  { render :action => 'rss', :formats => [:xml], :layout => false }
      format.txt  { render :action => 'text', :formats => [:html], :layout => false }
      format.email { render :action => 'email', :formats => [:html], :layout => false }
      format.ics { render :text => @talks.to_ics }
    end
  end

  # GET /show/day
  def day
    finder = TalkFinder.new(:start_time => @start_time, :end_time => @start_time + 1.day)
    @talks = list_or_all.find_public(:all, finder.to_find_parameters)
    respond_to do |format|
      format.html { render :partial => 'day' }
      format.json { render json: @talks }
    end
  end
  
  # GET /show/week
  def week
    finder = TalkFinder.new(:start_time => @start_time, :end_time => @start_time + 1.week, :reverse_order => true)
    @talks = list_or_all.find_public(:all, finder.to_find_parameters)
    respond_to do |format|
      format.html { render :partial => 'week' }
      format.json { render json: @talks }
    end
  end

  # GET /show/all
  def all
    finder = TalkFinder.new(:start_time => @start_time, :reverse_order => true)
    @talks = list_or_all.find_public(:all, finder.to_find_parameters)
    respond_to do |format|
      format.html { render :partial => 'week' }
      format.json { render json: @talks }
    end
  end
  
  # GET /show/stared
  def stared
    finder = TalkFinder.new(:start_time => @start_time, :reverse_order => true)
    @talks = User.current.lists.first.talks.find_public(:all, finder.to_find_parameters)
    respond_to do |format|
      format.html { render :partial => 'week' }
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
  
  def decode_time_period
    @list = List.find params[:id]
    finder = TalkFinder.new(params)
    @errors = finder.errors
    @talks = @list.talks.find( :all, finder.to_find_parameters)
  end
  
  # FIXME: Refactor so that can set this from url
  def decode_list_details
    @list_details = true
    true # Must return true for method to continue
  end	

  def start_time_from_start_date
    unless params[:start_date] && params[:start_date].length >= 8
      @start_time = Time.now.at_beginning_of_day
      return
    end
    if params[:start_date].length == 8
      year =  params[:start_date][0,4]
      month = params[:start_date][4,2]
      day   = params[:start_date][6,2]
      @start_time = Time.local year, month, day
    else
      @start_time = Time.at(params[:start_date].to_i)
    end
  end

  def list_or_all
    if params[:id]
      List.find(params[:id]).talks
    else
      Talk
    end
  end
end
