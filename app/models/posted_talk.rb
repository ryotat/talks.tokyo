class PostedTalk < ActiveRecord::Base
  attr_protected :speaker_id, :venue_id


  include TalkBase

  def ensure_speaker_initialized
    return if speaker.last_login # don't mess with real users' input
    speaker.name = speaker_name
    speaker.affiliation = speaker_affiliation
    newpassword = speaker.randomize_password
    logger.debug "New password for #{speaker.email}: #{newpassword}"
    self[:speaker_id] = speaker.id
  end
  
  def venue=(new_venue)
    @venue = new_venue
    self[:venue_id] = new_venue.id
  end
  def venue
    @venue ||= venue_id ? List.find(venue_id) : nil
  end

  def series=(new_series)
    @series = new_series
    self[:series_id] = new_series.id
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

end
