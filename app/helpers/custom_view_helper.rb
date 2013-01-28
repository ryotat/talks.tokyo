module CustomViewHelper
  
  def keep_url_in_sync_with_form( cview, form = '#viewform', urldiv = '#viewurl')
    content_tag 'script', "jQuery('#{form}').talks('observe_form','#{urldiv}', '#{custom_view_path(:action => "update", :id => cview)}')".html_safe
  end


end
