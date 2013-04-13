require 'openssl'
require 'webrick'
require 'base64'

class LoginController < ApplicationController

  # filter_parameter_logging :password

  before_filter :store_return_url_in_session

  ERROR = WEBrick::HTTPStatus::Unauthorized

#	def initialize
#	  @publickey = {}
#		raven_settings[:public_key_files].each { |id,filename| load_public_key( id, filename) }
#	end
	
	def store_return_url_in_session
    session["return_to"] = params[:return_url] if (params[:return_url] && params[:return_url] != '/login/logout')
	end
	
	def logout
	 User.current = nil
	 session[:user_id ] = nil
	 session["return_to"] = nil
	 flash[:confirm] = "You have been logged out."
	end
	
  def do_login
    user = User.find_by_email params[:email]
    if user
      if user.authenticate(params[:password])
        session[:user_id ] = user.id
        post_login_actions
    	else
  	    flash[:login_error] = "Password not correct"
  	    @email = user.email
  	    render :action => 'index'
  	  end
    else
      flash[:login_error] = "I have no record of this email"
      render :action => 'index'
    end
  end
  
  def send_password
    @user = User.find_by_email params[:email]
    if @user
      @user.send_password
      render :action => 'password_sent'
    else
      flash[:error] = "I'm sorry, but #{params[:email]} is not listed on this system. (note that is is case sensitive)"
      render :action => 'lost_password'
    end
  end
  
  def new_user
    @user = User.find session[:user_id]
  end
  
  def do_new_user
    user = User.find session[:user_id]
    user.name = params[:name] if params[:name]
    user.affiliation = params[:affiliation] if params[:affiliation]
    user.save
    user.subscribe_to_list( user.personal_list ) if params[:send_email] == '1'
    user.update_attribute :last_login, Time.now
    return_to_original_url
  end
  
  def return_to_original_url
    redirect_to original_url
  end
  
  private
  include CommonUserMethods
 
  def error( raven_code, *variables )
		raise ERROR.new( "Raven error #{raven_code}: #{RAVEN_ERRORS[raven_code]} : #{variables.join(' ')}" )
	end

	def load_public_key( id, filename )
		@publickey[ id ] = OpenSSL::PKey::RSA.new( IO.readlines( filename ).to_s )
	end

	# Takes a string with a time encoded according to rfc3339 (e.g. 20040114T123103Z) and returns a Time object.
	def timeforRFC3339( rfc3339 )
		year = rfc3339[ 0..3 ].to_i
		month = rfc3339[ 4..5 ].to_i
		day = rfc3339[ 6..7 ].to_i
		hour = rfc3339[ 9..10 ].to_i
		minute = rfc3339[ 11..12 ].to_i
		second = rfc3339[ 13..14 ].to_i
		return Time.gm( year, month, day, hour, minute, second)
	end	

	# Borrowed from CGI class to encode message to pass to raven
	def escape(string)
    string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
      '%' + $1.unpack('H2' * $1.size).join('%').upcase
    end.tr(' ', '+')	
	end

	# Borrowed from CGI class to decode messages from raven
	def unescape(string)
    string.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n) do
      [$1.delete('%')].pack('H*')
    end
	end
end
