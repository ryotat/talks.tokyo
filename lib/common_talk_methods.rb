module CommonTalkMethods
  def set_usual_details
    @usual_details ||= UsualDetails.new @talk.series
  end
  
  def user_can_edit_talk?
    return true if @talk.editable?
    false
  end
  
end
