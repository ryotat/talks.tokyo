class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_styles_update

  include CheckForUser # On each request, checks for user information in session or in header and sets User.current

  # This should be called after set_user defined in CheckForUser
  before_filter :set_locale

  def default_url_options(options={})
    return { :locale => I18n.locale } if params[:locale]
    {}
  end 

  private
  def set_locale
    I18n.locale = params[:locale] || (User.current && User.current.locale) || I18n.default_locale
  end
  
  def check_styles_update
    @styles_last_update = url_encode(List.where('style is not null').map(&:updated_at).max.to_s)
  end
  

end
