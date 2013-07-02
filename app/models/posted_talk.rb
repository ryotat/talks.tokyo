# == Schema Information
# Schema version: 20130607030122
#
# Table name: posted_talks
#
#  id                :integer          not null, primary key
#  title             :string(255)
#  abstract          :text
#  start_time        :datetime
#  end_time          :datetime
#  name_of_speaker   :string(255)
#  speaker_email     :string(255)
#  sender_ip         :string(255)
#  speaker_id        :integer
#  series_id         :integer
#  venue_id          :integer
#  abstract_filtered :text
#  language          :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ex_directory      :boolean
#

class PostedTalk < ActiveRecord::Base
  attr_protected :speaker_id, :venue_id
  validates :name_of_speaker, :presence => true
  validates :speaker_email, :presence => true

  include TalkBase

  def ensure_speaker_initialized
    return unless speaker.new_record? # don't mess with real users' input
    speaker.name = speaker_name
    speaker.affiliation = speaker_affiliation
    speaker.send_password # randomize password and save
    self[:speaker_id] = speaker.id
  end
  
  def venue=(new_venue)
    @venue = new_venue
    self[:venue_id] = new_venue.id if new_venue
  end
  def venue
    @venue ||= venue_id ? List.find(venue_id) : nil
  end

  def series=(new_series)
    @series = new_series
    self[:series_id] = new_series.id if new_series
  end
 
  def series
    @series ||= series_id ? List.find(series_id) : nil
  end

  def speaker_email
    speaker ? speaker.email : (speaker_email ? speaker_email : "")
  end
  
  def speaker_email=(email)
    self.speaker = User.find_or_create_by_email(email)
    self[:speaker_email] = email
  end

  def approvable?
    return false unless User.current
    User.current.administrator? or
      (series.users.include? User.current )
  end

  def notify_organizers
    series.users.each do |u|
      Mailer.notify_new_posted_talk(u, self).deliver
    end
  end

  def notify_approved(id)
    Mailer.notify_talk_approved(self, id).deliver
  end

end
