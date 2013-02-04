class HomeController < ApplicationController

  layout 'with_related'
  # GET /
  # GET /home
  # GET /home.json
  def index
    get_today
    @default_view = params[:period] || 'day'
    finder = TalkFinder.new(:id => List.find_or_create_by_name('Featured talks'), :start_time => @start_time, :reverse_order => true, :public => 1)
    @featured_talks = finder.find
    set_cal_path
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @featured_talks }
    end
  end

  private
  def get_today
    if params[:today]
      year =  params[:today][0,4]
      month = params[:today][4,2]
      day   = params[:today][6,2]
      @start_time = Time.local(year, month, day)
    else
      @start_time = Time.now.at_beginning_of_day
    end
    @today = @start_time.strftime('%Y%m%d')
  end

  def set_cal_path
    @cal_path = list_path(:target => '#talks-calendar', :format => 'calendar_with_talks', :trigger =>'click')
  end
end
