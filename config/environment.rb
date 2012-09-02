# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
TalksTokyo::Application.initialize!

require 'icalendar_extensions'

begin 
  require 'RMagick'
rescue LoadError
  gem 'RMagick'
end

# In Rails 3 user input is sanitized by default.
# http://railscasts.com/episodes/204-xss-protection-in-rails-3

RAVEN_SETTINGS = { 
  # :raven_url 		=> 'https://demo.raven.cam.ac.uk/auth/authenticate.html',  
   :raven_url 		=> 'https://raven.cam.ac.uk/auth/authenticate.html',
  :raven_version => '1',
  :max_skew 		=> 90, # seconds
  :public_key_files => { 2 => File.join(File.dirname(__FILE__), 'pubkey2.txt') },
#  :public_key_files => { 901 => File.join(File.dirname(__FILE__), 'pubkey901.txt') },
  :description 	=> 'the talks.cam website',
  :message 		=> 'we wish to track who makes what changes',
  :aauth 			=> [],
  :iact 			=> "",
  :match_response_and_request => true,
  :fail 			=> "",
  }

