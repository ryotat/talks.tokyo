module CommonTalkMethods
  def find_talk(klass=Talk)
    return nil unless params[:id]
    begin
      @talk = klass.find params[:id]
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def set_usual_details
    @usual_details ||= UsualDetails.new @talk.series
  end
  
  def user_can_edit_talk?
    return true if @talk.editable?
    false
  end
  
end
