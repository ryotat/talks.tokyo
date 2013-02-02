# -*- coding: utf-8 -*-
class Talk < ActiveRecord::Base
  attr_protected :organiser_id, :speaker_id

  def Talk.listed_in(list_ids)
    unless list_ids.is_a?(Array)
      list_ids = [list_ids]
    end
    Talk.joins list_ids.map.with_index { |list_id,i| :"INNER JOIN list_talks lt#{i} ON talks.id = lt#{i}.talk_id AND lt#{i}.list_id IN #{list_id.is_a?(Array)?'('+list_id.join(',')+')': '('+list_id.to_s+')'}" }.join(" ")
  end

  def Talk.find_public(*args)
    Talk.with_scope(:find => {:conditions => "ex_directory = 0 AND title != 'Title to be confirmed'"}) do
      Talk.find(*args)
    end
  end
  
  def Talk.random_and_in_the_future(number_of_talks_to_find = 1, exclude_talk_id = 0 )
    Talk.find_public(:all,  :order => 'RAND()', 
                            :limit => number_of_talks_to_find, 
                            :conditions => ["id != ? AND start_time > ?",exclude_talk_id,Time.now])
  end
  
  def Talk.sort_field; 'title' end

  include TalkBase
  include Relatable # To have related lists and talks
  
  # Link tables
  has_many :list_talks, :dependent => :destroy, :extend => FindDirectExtension
  
  # Interesting relationships
  belongs_to  :organiser, :foreign_key => 'organiser_id', :class_name => 'User'
  belongs_to  :series, :class_name => 'List', :foreign_key => 'series_id'
  belongs_to  :venue, :class_name => 'List', :foreign_key => 'venue_id'
  has_many    :lists, :through => :list_talks, :extend => FindDirectExtension 
   
  # This is to allow a custom image to be loaded
  include BelongsToImage
  
  before_save :check_if_venue_or_series_changed
  after_save  :add_to_lists
  after_save  :possibly_send_the_speaker_an_email

  def sort_of_delete
    self.ex_directory = true
    self.special_message = "This talk has been canceled/deleted"
    self.save
    
    ListTalk.delete_all ['talk_id = ?',id]
    true # So can continue
  end

  # If so, should not mess with the ex_directory attribute
  def canceled?
    special_message == "This talk has been canceled/deleted"
  end
  
  def check_if_venue_or_series_changed
    return @new_series_and_venue = true if new_record?
    old_talk = Talk.find(id)
    @old_venue = old_talk.venue unless self.venue_id == old_talk.venue_id
    @old_series = old_talk.series unless self.series_id == old_talk.series_id
  end
  
  # Make sure the talk is part of the venue and series lists
  def add_to_lists
    series.add(self) if (series && @new_series_and_venue || @old_series)
    venue.add(self) if (venue && @new_series_and_venue || @old_venue)
    @old_series.remove(self) if @old_series
    @old_venue.remove(self) if @old_venue
  end
  
  # To allow duck-typing with a list
  def name; title end
  def details; abstract end

  # Short cut to the series name
  def series_name
    series ? series.name : ""
  end
  
  def series_name=(new_series_name)
    self.series = new_series_name.blank? ? nil : List.find_or_create_by_name_while_checking_management(new_series_name)
  end
  
  # Short cut to organiser email
  def organiser_email
    organiser ? organiser.email : ""
  end
  
  def organiser_email=(email)
    self.organiser = email.blank? ? nil : User.find_or_create_by_email(email)
  end
  
  attr_accessor :send_speaker_email
  
  def possibly_send_the_speaker_an_email
    return unless send_speaker_email == '1'
    return true unless speaker_email && speaker_email =~ /.*?@.*?\..*/
    Mailer.speaker_invite( speaker, self ).deliver
  end
  
  # FIXME: Refactor with the code in the show controller
  def term
    return nil unless start_time
    case start_time.mon
     when 1..3 # Lent term
       return month_range( start_time.year, 1, 3 )
     when 4..6 # Easter term
       return month_range( start_time.year, 4, 6 )
     when 7..9 # Long vac.
       return month_range( start_time.year, 7, 9 )
     when 10..12 # Michaelmas term
       return month_range( start_time.year, 10, 12 )
     end
  end
    
  
    def to_ics
      [
        'BEGIN:VEVENT',
        "CATEGORIES:#{series && series.name && series.name.to_ics}",
        "SUMMARY:#{"#{title} - #{name_of_speaker}".to_ics}",
        "DTSTART:#{start_time && start_time.getgm.to_s(:ics)}",
        "DTEND:#{end_time && end_time.getgm.to_s(:ics)}",
        "UID:TALK#{id}AT#{ActionController::Base.asset_host}",
        "URL:#{HOST}/talk/index/#{id}",
        "DESCRIPTION:#{abstract && abstract.to_ics}",
        "LOCATION:#{venue && venue.name && venue.name.to_ics}",
        "CONTACT:#{organiser && organiser.name && organiser.name.to_ics}",
        "END:VEVENT"
      ].join("\r\n")
    end
  
  private
  
  # FIXME: Refactor with the code in the show controller
	def month_range( year, start_month, end_month )
	 return Time.local( year, start_month ).at_beginning_of_month, Time.local(year,end_month).at_end_of_month
	end
  
end

