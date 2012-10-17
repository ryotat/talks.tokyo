module CustomViewHelper
  
  def keep_url_in_sync_with_form( cview, form = 'viewform', urldiv = 'viewurl')
    observe_form form,  {   :url => { :action => 'update', :id => cview }, 
                            :update => urldiv,
                            :loading => "Element.update('#{urldiv}','Updating the link');",
                            :complete => "new Effect.Highlight('#{urldiv}');"
                        }
  end

  def url_area( custom_view )
    partial = case custom_view.view_parameters['layout']
              when 'embed','embedcss'
                'embed_url'
              else
                'url'
              end 
      render  :partial => partial, :locals => {:custom_view => custom_view}
  end
  
end
