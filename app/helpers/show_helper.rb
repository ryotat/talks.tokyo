module ShowHelper
  def body_class
    'list'
  end
  
  def upcoming_link(today)
    count = Talk.listed_in([@list.id_all]).where('start_time >= ?', today).count
    unit  = 'upcoming talk'.pluralize(count)
    count_unit = content_tag('b', count)+" "+unit
    unless request.fullpath == list_path( :id => @list.id, :period => 'upcoming', :today => today.strftime('%Y%m%d'))
      link_to count_unit, list_path( :id => @list.id, :period => 'upcoming', :today => today.strftime('%Y%m%d')), :class => 'btn'
    else
      link_to count_unit, '#', :class => 'btn disabled'
    end
  end
  
  def archive_link(today)
    max = 500
    # Have to use Talk.count rather than @list.talks.count since Ruby 1.8.7 as it seems to call Array.count instead :(
    count = Talk.listed_in([@list.id_all]).where('start_time < ?', today).count
    unit  = "#{'talk'.pluralize(count)} in the archive"
    count_unit = content_tag('b',count)+" "+unit
    unless request.fullpath == list_path( :id => @list.id, :period => 'archive', :only_path => true, :today => today.strftime('%Y%m%d')  )
      if count > max && request.fullpath != list_path( :id => @list.id, :period => 'archive', :limit => max, :today => today.strftime('%Y%m%d') )
        link_to count_unit+": show first #{max}", list_path( :id => @list.id, :period => 'archive', :limit => max, :today => today.strftime('%Y%m%d') ), :class => 'btn'
      else
        link_to count_unit+"#{ count > max ? ': show all (slow!)' : '' }", list_path( :id => @list.id, :period => 'archive',:today => today.strftime('%Y%m%d') ), :class => 'btn'
      end
    else
      link_to count_unit, '#', :class => 'btn disabled'
    end
  end

  def add_list_to_list_button
    if User.current
      if User.current.only_personal_list?
        icon_button 'icon-star',  *add_list_to_list_contents, :id => 'add-list-to-list-button', :remote => true
      else
        icon_button 'icon-check', *add_list_to_list_contents, :data => {:id => 'modal'}, :rel => 'talks-modal'
      end
    end
  end
  
  def usual_details( threshold = 0.75 )
    return @usual_details if @usual_details
    threshold = @talks.size * threshold
    @usual_details = {:name_of_speaker => nil, :series => nil, :start_time => nil, :venue_name => nil, :time_slot => nil}
    @usual_details.keys.each do |parameter|
      values = {}
      @talks.each do |talk|
        value = talk.send(parameter)
        values[value] = (values[value] || 0) + 1 
      end
      sorted_values = values.sort_by { |k,v| v }
      if sorted_values.last.last >= threshold
        @usual_details[parameter] = sorted_values.last.first
      end
    end
    @usual_details
  end

  def unusual?(talk,parameter)
    talk.send(parameter) != usual_details[parameter]
  end
  
  # FIXME: Refactor
  def term_string( term )
    case term.first.mon
    when 1..3 # Lent term
      "Lent Term #{term.first.year}"
    when 4..6 # Easter term
      "Easter Term #{term.first.year}"
    when 7..9 # Long vac.
      "Long Vacation #{term.first.year}"
    when 10..12 # Michaelmas term
      "Michaelmas Term #{term.first.year}"
    end  
  end
  
  def cam_time_format( timestring )
    timestring.downcase.gsub(/0(?=\d\.)/,'').gsub(/\.00/,'')
  end
  
end
	
