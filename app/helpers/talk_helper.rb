module TalkHelper
  
  def update_field(field,title,value=title)
    link_to_function title, "setField('#{field}','#{value}')"
  end
  
  def set_user_details( user, prefix='talk_' )
    link_to_function "#{user.name} (#{user.affiliation}) - #{user.email}","setSpeaker('#{user.name} (#{user.affiliation})','#{user.email}','#{prefix}')"
  end
  
  def body_class
    'list talk'
  end

  def contact_organizer_button
    icon_button 'icon-user', 'Contact the organiser', user_path(:id => @talk.organiser)
  end
  def tell_a_friend_button
    icon_button 'icon-envelope', 'Tell a friend', tell_a_friend_path('tickle[about_id]' => @talk.id, 'tickle[about_type]' => 'Talk'), true
  end
  def text_button
    icon_button 'icon-file', 'View as plain text', talk_path(:format => 'txt', :id => @talk.id)
  end
  def vcal_button
    icon_button 'icon-calendar', 'Download to your calendar using vCal', talk_path(:action => 'vcal', :id => @talk.id)
  end
  def add_talk_to_list_button
    icon_button 'icon-star', *add_talk_to_list_contents
  end
  def add_talk_to_list_link
    link_to *add_talk_to_list_contents
  end
  def add_talk_to_list_contents
    if User.current && User.current.has_added_to_list?( @talk )
      if User.current.only_personal_list?
        return 'Remove from your list(s)', include_talk_path(:action => 'destroy', :child => @talk)
      else
        return 'Add/Remove from your list(s)', include_talk_path(:action => 'create', :child => @talk)
      end
    else
      return 'Add to your list(s)',include_talk_path(:action => 'create', :child => @talk)
    end
  end
end
