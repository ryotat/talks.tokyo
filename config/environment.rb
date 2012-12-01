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

