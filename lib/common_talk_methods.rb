module CommonTalkMethods
  def set_usual_details
    @usual_details ||= UsualDetails.new @talk.series
  end
  
  def user_can_edit_talk?
    return true if @talk.editable?
    render :text => "Permission denied", :status => 401
    false
  end
  
  def return_404
    raise ActiveRecord::RecordNotFound.new
  end    
end
