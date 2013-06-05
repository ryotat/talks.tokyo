class HomeController < ApplicationController

  layout 'with_related'
  # GET /
  # GET /home
  # GET /home.json
  def index
    get_today
    @default_view = params[:period] || 'day'
    finder = TalkFinder.new(:id => List.find_or_create_by_name('Featured talks'), :end_time => @today, :ascending => false, :public => 1)
    @past_talks = finder.find
    finder = TalkFinder.new(:start_time => @today, :end_time => @today + 1.month, :ascending => true, :public => 1)
    @upcoming_talks = finder.find
    set_cal_path
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @upcoming_talks }
    end
  end

  private
  def get_today
    if params[:today]
      year =  params[:today][0,4]
      month = params[:today][4,2]
      day   = params[:today][6,2]
      @today = Time.local(year, month, day)
    else
      @today = Time.now.at_beginning_of_day
    end
  end

  def set_cal_path
    @cal_path = list_path('all',:target => '#talks-calendar', :format => 'calendar_with_talks', :trigger =>'click', :date => @today.strftime('%Y/%m/%d'))
  end
end
