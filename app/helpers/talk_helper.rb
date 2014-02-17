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

  def div_talk(options ={}, &block)
    content_tag 'div', options.merge(:itemprop => "event", :itemscope => true,  :itemtype => "http://schema.org/Event"), &block
  end
  
  def talk_title(talk)
    content_tag 'span', talk.title, :itemprop => "name"
  end

  def talk_speaker(talk)
    link_to_if(talk.speaker, content_tag('span',talk.name_of_speaker, :itemprop => "performer"), talk.speaker)
  end

  def talk_abstract(talk)
    content_tag 'span', talk.abstract_filtered.html_safe, :itemprop => "description"
  end

  def talk_venue(talk)
    link_list(talk.venue)
  end

  def contact_organizer_button
    icon_link 'icon-user', 'Organiser', @talk.organiser && user_path(@talk.organiser)
  end
  def tell_a_friend_button
    icon_link 'icon-envelope', 'Tell a friend', new_tickle_path('tickle[about_id]' => @talk.id, 'tickle[about_type]' => 'Talk'), :rel => 'talks-modal'
  end
  def text_button
    icon_link 'icon-file', 'View as plain text', talk_path(@talk, :format => 'txt')
  end
  def ics_button
    icon_link 'icon-calendar', 'Download iCalendar', talk_path(@talk, :format => 'ics')
  end
  def add_talk_to_list_button
    if User.current.nil? || User.current.only_personal_list?
      contents=add_talk_to_list_contents
      options=contents[-1].merge(:remote => true, :id => 'create-association-button')
      icon_link 'icon-star',  *contents[0..1], options
    else
      icon_link 'icon-check', *add_talk_to_list_contents, :rel => 'talks-modal'
    end
  end
  def add_talk_to_list_link
    link_to *add_talk_to_list_contents
  end
  def add_talk_to_list_contents
    if User.current.nil? || User.current.only_personal_list?
      if User.current && User.current.has_added_to_list?( @talk )
        return 'Remove from your list', talk_associations_path(@talk), :method => :delete
      else
        return 'Add to your list', talk_associations_path( @talk), :method => :post
    end
    else
      return 'Add/Remove from your lists', new_talk_association_path(@talk)
    end
  end
  def edit_special_message_button
    if @talk.editable?
      icon_link 'icon-pencil', 'Edit', edit_talks_special_message_path(@talk), :class => "hide", :rel => 'talks-modal'
    end
  end
  def print_button
    link_to_function icon_tag('icon-print')+"Print this page", "window.print();"
  end
end
