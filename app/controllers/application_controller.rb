class ApplicationController < ActionController::Base
  protect_from_forgery

  include CheckForUser # On each request, checks for user information in session or in header and sets User.current

  private


end
