class VenuesController < ApplicationController
  before_filter :ensure_user_is_logged_in, :except => [:show]

  def index
    if User.current.administrator?
      @venues = Venue.find(:all)
    else
      @venues = User.current.venues
    end
  end

  def show
  end
end
