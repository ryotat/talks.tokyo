class HomeController < ApplicationController

  layout 'with_related'
  # GET /
  # GET /home
  # GET /home.json
  def index
    get_start_date
    finder = TalkFinder.new(:start_date => @start_date, :reverse_order => true)
    @featured_talks = List.find_or_create_by_name('Featured talks').talks.find_public(:all, finder.to_find_parameters)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @featured_talks }
    end
  end

  private
  def get_start_date
    if params[:start_date]
      @start_date = params[:start_date]
    else
      @start_date = Time.now.at_beginning_of_day.strftime('%Y%m%d')
    end
  end
end
