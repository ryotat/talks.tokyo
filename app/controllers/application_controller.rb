class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  include CheckForUser # On each request, checks for user information in session or in header and sets User.current
 
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  private


end
