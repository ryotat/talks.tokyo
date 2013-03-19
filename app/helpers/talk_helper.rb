module TalkHelper
  
  def update_field(field,title,value=title)
    link_to_function title, "jQuery('##{field}').talks('setField','#{value}')".html_safe
  end
  
  def set_user_details( user, prefix='talk_' )
    link_to_function "#{user.name} (#{user.affiliation}) - #{protect_email(user.email)}","setSpeaker('#{user.name} (#{user.affiliation})','#{user.email}','#{prefix}')"
  end
  
  def body_class
    'list talk'
  end

  def icon_link(klass, text, url, options={})
    link_to icon_tag(klass)+text, url, options
  end

  def contact_organizer_button
    icon_link 'icon-user', 'Organiser', user_path(:id => @talk.organiser)
  end
  def tell_a_friend_button
    icon_link 'icon-envelope', 'Tell a friend', new_tickle_path('tickle[about_id]' => @talk.id, 'tickle[about_type]' => 'Talk'), :rel => 'talks-modal'
  end
  def text_button
    icon_link 'icon-file', 'View as plain text', talk_path(@talk, :format => 'txt')
  end
  def vcal_button
    icon_link 'icon-calendar', 'Download vCal', talk_path(@talk, :format => 'vcal')
  end
  def add_talk_to_list_button
    if User.current
      if User.current.only_personal_list?
        contents=add_talk_to_list_contents
        options=contents[-1].merge(:remote => true, :id => 'create-association-button')
        icon_link 'icon-star',  *contents[0..1], options
      else
        icon_link 'icon-check', *add_talk_to_list_contents, :rel => 'talks-modal'
      end
    end
  end
  def add_talk_to_list_link
    link_to *add_talk_to_list_contents
  end
  def add_talk_to_list_contents
    if User.current.only_personal_list?
      if User.current.has_added_to_list?( @talk )
        return 'Remove from your list', talk_associations_path(@talk), :method => :delete
      else
        return 'Add to your list(s)', talk_associations_path( @talk), :method => :post
    end
    else
      return 'Add/Remove from your list(s)', new_talk_association_path(@talk)
    end
  end
  def edit_special_message_button
    if @talk.editable?
      icon_link 'icon-pencil', 'Edit', edit_talks_special_message_path(@talk), :rel => 'talks-modal', :style => "display:none"
    end
  end
end
