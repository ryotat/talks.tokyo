xml.instruct!

xml.rss(
  'version'  => '2.0',
  'xmlns:cf' => "http://www.microsoft.com/schemas/rss/core/2005",
  'xmlns:ev' => "http://purl.org/rss/1.0/modules/event/"
  ) do
  xml.channel do 
    # Microsoft list extension
    xml.cf :treatAs, 'list'
    xml.cf :listinfo do
      xml.cf :sort, 
            :label => "Start time", 
            :default => "true",
            :ns => "http://purl.org/rss/1.0/modules/event/",
            :element => 'startdate',
            'data-type' => "date"
    end
    
    xml.title @list.name
    xml.link list_url(:id => @list.id)
    xml.managingEditor @list.users.first.name if @list.users.first
    xml.pubDate CGI.rfc1123_date(Time.now)
    
    # There appears no be no place in RSS to show an error message, so we shoe-horn it into the description
    details = @list.details
    @errors.each do |error|
      details << " Error:" << error << "."
    end
    xml.description details
    
    @talks.each do |talk|
      next unless talk.ready?
      xml.item do
        xml.title "#{talk.start_time.strftime('%a %d %b %H:%M:')} #{talk.title} #{talk.special_message}"
        xml.description render(:partial => "rss_talk", :formats => [:html], :locals => {:talk => talk})
		    
		    xml.pubDate CGI.rfc1123_date(talk.updated_at || talk.created_at || Time.now )
		    xml.link talk_url(:id => talk.id)
		    xml.guid "#{talk_url(:id => talk.id)}##{talk.updated_at.to_i}"
		    
		    # Using the event module 'standard'
		    xml.ev :startdate, talk.start_time.strftime('%Y-%m-%dT%H:%M') # ISO 8601
	    	xml.ev :enddate, talk.end_time.strftime('%Y-%m-%dT%H:%M') # ISO 8601
	    	xml.ev :location, talk.venue_name
	    	xml.ev :organizer, talk.organiser.name if talk.organiser 
      end
    end
  end
end
