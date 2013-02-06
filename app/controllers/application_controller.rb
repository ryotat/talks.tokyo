class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  before_filter :check_styles_update

  include CheckForUser # On each request, checks for user information in session or in header and sets User.current

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => I18n.locale }
  end 

  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
  def check_styles_update
    @styles_last_update = url_encode(List.where('style is not null').map(&:updated_at).max.to_s)
  end
  

end
