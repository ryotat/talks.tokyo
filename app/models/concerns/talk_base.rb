# -*- coding: utf-8 -*-
require 'active_support/concern'

module TalkBase
  extend ActiveSupport::Concern

  included do
    belongs_to  :speaker, :foreign_key => 'speaker_id', :class_name => 'User'

    include TextileToHtml # To convert abstract
    include CleanUtf # To try and prevent any malformed utf getting in

    # validate the time strings.  This method keeps as close as possible to Tom's original validation (just the regexp), while also checking it can be parsed into a real time (so no 25:76 entries)
    validates_each :start_time_string, :end_time_string do |record, attr, value|
      if not value.blank?
        if value =~ %r{\d+:\d+}
          begin
            Time.parse(value)
          rescue ArgumentError
            record.errors.add(attr)
          end
        else
          record.errors.add(attr)
        end
      end
    end


    # validate the date.  This method keeps as close as possible to Tom's original validation (just the regexp), while also checking it can be parsed into a real date (so no 2008/12/12312 entries)
    validates_each :date_string do |record, attr, value|
      if not value.blank?
        if value =~ %r{\d\d\d\d/\d+/\d+}
          begin
            Date.parse(value)
          rescue ArgumentError
            record.errors.add(attr)
          end
        else
          record.errors.add(attr)
        end
      end
    end

    before_save :update_html_for_abstract
    before_save :ensure_speaker_initialized
    after_validation :update_start_and_end_times_from_strings

  end

  # Tries to figure these out from the name of speaker field if no speaker given
  def speaker_name
    return "" unless self.name_of_speaker
    self.name_of_speaker[/^\s*([^,(]*)/,1].strip
  end
  
  def speaker_affiliation
    return "" unless self.name_of_speaker
    self.name_of_speaker[/[,(]([^)]*)[)]?/,1] || ""
  end

  # Short cut to speaker email
  def speaker_email
    speaker ? speaker.email : ""
  end
  
  def speaker_email=(email)
    self.speaker = User.find_or_create_by_email(email) # this will fail if email does not exists because the password is empty.
  end

  # Short cut to the series name
  def series_name
    series ? series.name : ""
  end
  
  def series_name=(new_series_name)
    self.series = new_series_name.blank? ? nil : List.find_or_create_by_name_while_checking_management(new_series_name)
  end
  
  # Short cut to the venue name
  def venue_name
    venue ? venue.name : ""
  end
  
  def venue_name=(new_venue_name)
    self.venue = new_venue_name.blank? ? nil : Venue.find_or_create_by_name_with_management_update(new_venue_name)
  end
  
  def ensure_speaker_initialized
    return if speaker_email.empty? # don't register a user if email is empty
    return unless speaker.new_record? # don't mess with real users' input
    speaker.name = speaker_name
    speaker.affiliation = speaker_affiliation
    speaker.randomize_password # but don't send email
    self.speaker = speaker
  end

  # This is used to transform the textile in abstract into redcloth
  def update_html_for_abstract
    return unless abstract
    self.abstract_filtered = textile_to_html( abstract )
  end

  def update_start_and_end_times_from_strings
    #Don't try to run this unless we have sensible strings to work with
    return unless @start_time_string && @end_time_string &&  !@date_string.blank? && errors.count==0
    year,month, day = date_string.split('/')
    start_hour, start_minute = start_time_string.split(':')
    end_hour, end_minute = end_time_string.split(':')
    self.start_time = Time.local year, month, day, start_hour, start_minute
    self.end_time = Time.local year, month, day, end_hour, end_minute
    true
  end

  # For security
  def editable?
    return false unless User.current
    User.current.administrator? or
      (speaker == User.current ) or
      (series.users.include? User.current )
  end
  
  # This provides the talks start and end time in 
  # a format convenient for using in the create talk
  # feature
  def time_slot
    return nil unless start_time && end_time
    [ sprintf("%d:%02d", start_time.hour, start_time.min),
      sprintf("%d:%02d", end_time.hour, end_time.min) ]
  end
  
  def set_time_slot( date, start, finish )
    year,month, day = [date.year, date.month, date.day]
    start_hour, start_minute = start.split(':')
    end_hour, end_minute = finish.split(':')
    self.start_time = Time.zone.local year, month, day, start_hour, start_minute
    self.end_time = Time.zone.local year, month, day, end_hour, end_minute
  end
  
  def date
    return nil unless start_time
    start_time.to_date
  end
  
  def date_string
    @date_string || (start_time && start_time.strftime('%Y/%m/%d'))
  end
  attr_writer :date_string
  
  def start_time_string
    @start_time_string || (start_time && start_time.strftime('%H:%M'))
  end
  attr_writer :start_time_string
  
  def end_time_string
    @end_time_string || (end_time && end_time.strftime('%H:%M'))
  end
  attr_writer :end_time_string

end
