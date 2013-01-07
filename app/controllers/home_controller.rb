class HomeController < ApplicationController

  layout 'with_related'
  # GET /
  # GET /home
  # GET /home.json
  def index
    time_from_parameters
    @featured_talks = List.find_or_create_by_name('Featured talks').talks
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: [@talks,@featured_talks] }
    end
  end

  # GET /home/day
  def day
    time_from_parameters
    finder = TalkFinder.new(:start_time => @start_time, :end_time => @start_time + 1.day)
    @talks = Talk.find_public(:all, finder.to_find_parameters)
    respond_to do |format|
      format.html { render :partial => 'day' }
      format.json { render json: @talks }
    end
  end
  
  # GET /home/week
  def week
    time_from_parameters
    finder = TalkFinder.new(:start_time => @start_time, :end_time => @start_time + 1.week, :reverse_order => true)
    @talks = Talk.find_public(:all, finder.to_find_parameters)
    respond_to do |format|
      format.html { render :partial => 'week' }
      format.json { render json: @talks }
    end
  end

  # GET /home/all
  def all
    time_from_parameters
    finder = TalkFinder.new(:start_time => @start_time, :reverse_order => true)
    @talks = Talk.find_public(:all, finder.to_find_parameters)
    respond_to do |format|
      format.html { render :partial => 'all' }
      format.json { render json: @talks }
    end
  end
  
  # GET /home/stared
  def stared
    time_from_parameters
    finder = TalkFinder.new(:start_time => @start_time, :reverse_order => true)
    @talks = User.current.lists.first.talks.find_public(:all, finder.to_find_parameters)
    respond_to do |format|
      format.html { render :partial => 'all' }
      format.json { render json: @talks }
    end
  end

  def time_from_parameters
    unless params[:start_time] && params[:start_time].length >= 8
      @start_time = Time.now.at_beginning_of_day
      return;
    end
    if params[:start_time].length == 8
      year =  params[:start_time][0,4]
      month = params[:start_time][4,2]
      day   = params[:start_time][6,2]
      @start_time = Time.local year, month, day
    else
      @start_time = Time.at(params[:start_time].to_i)
    end
  end
end
