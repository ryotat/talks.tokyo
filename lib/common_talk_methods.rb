module CommonTalkMethods
  def set_usual_details
    @usual_details ||= UsualDetails.new @talk.series
  end
  
  def user_can_edit_talk?
    return true if @talk.editable?
    false
  end
  
  def page404
    render :file => "public/404", :format => [:html], :status => :not_found, :layout => false
    false
  end

  def page403
    render :file => "public/403", :format => [:html], :status => 403, :layout => false
    false
  end
end
