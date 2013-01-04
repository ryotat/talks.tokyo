class HomeController < ApplicationController

  layout 'home'
  # GET /
  # GET /index
  # GET /index.json
  def index
    finder = TalkFinder.new()
    if User.current
      lists = User.current.lists
      personal_list = lists.first
      @talks = personal_list.talks.find(:all, finder.to_find_parameters)
      (personal_list.children | lists[1,lists.length-1]).map { |c| @talks |= c.talks.find(:all, finder.to_find_parameters) }
      @talks = @talks.sort_by { |t| t.start_time }
    end
    @featured_talks = List.find_or_create_by_name('Featured talks').talks
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: [@talks,@featured_talks] }
    end
  end
end
