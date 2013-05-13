# -*- coding: utf-8 -*-
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def auto_discovery_link
    if params[:controller]=='show' && @list
      auto_discovery_link_tag(:rss, list_path(@list, :format => :rss))
    end
  end
 
  def show_flash
    [:error, :warning, :confirm].map { |name| flash[name] ? content_tag('div', flash[name], :class => "alert alert-%s"%(name == :confirm ? "success" : "error"))  : "" }.join.html_safe
  end
  
  def document(name, include_arrow = false, link_text = name )
    if include_arrow
      link_to sanitize(link_text)+arrow, document_path(name ), {:class => 'click'}
    else
      link_to sanitize(link_text), document_path(name ), {:class => 'click'}
    end
  end

  def add_list_to_list_contents
    if User.current.only_personal_list?
      if User.current.has_added_to_list?( @list )
        return 'Remove from your list', list_associations_path(@list), :method => :delete
      else
        return 'Add to your list', list_associations_path(@list), :method => :post
      end
    else
      return 'Add/Remove from your lists', new_list_association_path(@list)
    end
  end
  def add_list_to_list_link
    link_to *add_list_to_list_contents
  end

  def format_time_of_talk( talk, withyear=false )
    return "Time not fully specified" unless talk.start_time && talk.end_time
    time_tag(talk.start_time, format_date(talk.start_time, withyear)+", "+talk.start_time.strftime('%H:%M'), :itemprop=> "startDate")+"-"+time_tag(talk.end_time, :format => '%H:%M', :itemprop => "endDate")
  end

  def format_date( date, withyear=true )
    if I18n.locale==:ja
      wdays = ["日", "月", "火", "水", "木", "金", "土"]
      if withyear || Time.now.year != date.year || (Time.now-date).abs > 6.month
        date.strftime("%Y/#{date.month}/#{date.day} (#{wdays[date.wday]})")
      else
        date.strftime("#{date.month}/#{date.day} (#{wdays[date.wday]})")
      end
    else
      if withyear || Time.now.year != date.year || (Time.now-date).abs > 6.month
        date.strftime("%A #{date.day.ordinalize} %B %Y")
      else
        date.strftime("%A #{date.day.ordinalize} %B")
      end
    end
  end

  def format_wday(date)
    if I18n.locale==:ja
      wdays = ["日", "月", "火", "水", "木", "金", "土"]
      wdays[date.wday]
    else
      date.strftime("%A")
    end
  end

  def format_hours_of_talk( talk, abbr = true )
    return "Time not fully specified" unless talk.start_time && talk.end_time
    if abbr
      "<abbr style='border:none' class='dtstart' title='#{time_to_ical talk.start_time}'>#{talk.start_time.strftime('%H:%M')}</abbr>-<abbr style='border:none' class='dtend' title='1#{time_to_ical talk.end_time}'>#{talk.end_time.strftime('%H:%M')}</abbr>"
    else
      "#{talk.start_time.strftime('%H:%M')}-#{talk.end_time.strftime('%H:%M')}"
    end
  end
  
  def arrow(alttext = 'details')
    image_tag('redarrow.gif', :alt => alttext).html_safe
  end
  
  def logo( object, size = :small ) 
    case object
    when Talk
      if object.image_id?
        logo_tag( object, size )
      elsif object.speaker
        logo object.speaker, size
      elsif object.series
        logo object.series, size
      else
        ""
      end
    when List
      if object.image_id?
        logo_tag object, size
      else
        ""
      end
    when User
      if object.image_id?
        logo_tag object, size
      else
        ""
      end
    end
  end
  
  def logo_tag( object, size = :small )
    return "" unless object.image_id?
    url = case size
          when :small; picture_url(:id => object.image_id, :geometry => '32x32' )
          when :medium; picture_url(:id => object.image_id, :geometry => '128x128' )
          else; picture_url(:id => object.image_id, :geometry => size )
          end
    image_tag url, :alt => "#{object} logo", :class => 'logo'
  end
  
  def cluster_by_date( talks ) 
    h = Hash.new
    talks.each do |talk|
      h[ talk.start_time.to_date ] ||= []
      h[ talk.start_time.to_date ] << talk
    end
    return h.sort
  end
  
  def link_talk( talk )
    return "No talk" unless talk
    if talk.instance_of?(PostedTalk)
      link_to talk.title, posted_talk_path(talk)
    else
      link_to talk.title, talk_url(talk)
    end
  end
  
  def link_list( list, current=nil, klass='' )
    return "No list" unless list
    klass += ' disabled' if list==current
    link_to list.name, list_url(:id => list), :class => klass
  end
  
  def link_user( user )
    return 'nobody' unless user
    link_to user.name || user.email[/[^@]*/], user_url(:id => user)
  end
  
  def page_title
    [SITE_NAME,@list && @list.name, @talk && @talk.title, @user && @user.name ].compact.join(' : ')
   end
   
   def javascripts
     javascript_include_tag("application").html_safe
   end

   def stylesheets
     stylesheet_link_tag("application", :media => "screen,print").html_safe
   end
   
   def mybreadcrumbs
    return unless @list || @talk || @user || @child
    if @child.is_a?(Talk)
      @talk=@child
    elsif @child.is_a?(List)
      @list=@child
    end
    if @list && @list.id
      "<li><span class='divider'>></span>#{link_list(@list)}</li>".html_safe
    elsif @talk && @talk.id
      "<li><span class='divider'>></span>#{link_list(@talk.series)}</li><li><span class='divider'>></span>#{link_talk(@talk)}</li>".html_safe
    elsif @user && @user.id
      "<li><span class='divider'>></span>#{link_user(@user)}</li>".html_safe
    end
   end
   
   def body_class
    'application'
   end
   
   # FIXME: Refactor this somewhere else
   # Code borrowed from icalendar gem
   def time_to_ical( time )
       s = ""

       # 4 digit year
       s << time.year.to_s

       # Double digit month
       s << "0" unless time.month > 9 
       s << time.month.to_s

       # Double digit day
       s << "0" unless time.day > 9 
       s << time.day.to_s

       s << "T"

       # Double digit hour
       s << "0" unless time.hour > 9 
       s << time.hour.to_s

       # Double digit minute
       s << "0" unless time.min > 9 
       s << time.min.to_s

       # Double digit second
       s << "0" unless time.sec > 9 
       s << time.sec.to_s

       # UTC time gets a Z suffix
       #s << "Z"
      
       s
     end
     
     def escape_for_ical( string )
       [ ["\\","\\\\\\"],[/\r\n/,'\n' ],[/\n/,'\n' ], [',','\,'],[';','\;'] ].each do |substition|
         string = string.gsub *substition
       end
       string
     end

     def link_to_date( talk )
       date=talk.start_time
       link_to format_time_of_talk(talk), home_url(:today => date.strftime('%Y%m%d'))
     end
     
     def link_to_language( talk )
       link_to "#{t :language} : #{t talk.language}", list_url(:id => talk.series.id, :language => talk.language) 
     end
     
     def link_to_sign_in
       link_to 'Sign in', (params[:controller]=='login' && params[:action]=='logout') ? login_path : login_path(:return_url => request.fullpath)
     end

     def protect_email( email )
         email.gsub(/([\w]+)@([\w]+)\..+/) { "#{$1}@#{$2}..." }
     end

     def icon_button( klass, tooltip, url, options={})
       options[:rel] ||=""; options[:rel]+=' tooltip'
       link_to icon_tag(klass), url, options.merge(:class => 'btn', :title => tooltip)
     end

     def icon_tag(klass)
       content_tag('i','', :class=> klass)
     end

     def my_observe_field(field, opt ={})
       content_tag :script, "jQuery('#{field}').talks('observe_field', '#{opt[:update]}', function(value) { return #{opt[:url]} });".html_safe
     end

     def with_content_tag(tag, content)
       if content
         content_tag tag, content
       end
     end
     def locale_options
       {t(:en) => "en", t(:ja) => "ja"}
     end
     def my_error_messages_for(obj)
       if obj.errors.messages.length>0
         content_tag :div,
         content_tag(:ul, obj.errors.full_messages.map { |msg|
         content_tag(:li, msg) }.join.html_safe), :class => "alert alert-error" 
       end
     end
end
