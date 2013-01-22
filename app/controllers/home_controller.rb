class HomeController < ApplicationController

  layout 'with_related'
  # GET /
  # GET /home
  # GET /home.json
  def index
    get_today
    @default_view = params[:period] || 'day'
    finder = TalkFinder.new(:start_time => @start_time, :reverse_order => true)
    @featured_talks = List.find_or_create_by_name('Featured talks').talks.find_public(:all, finder.to_find_parameters)
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
end
