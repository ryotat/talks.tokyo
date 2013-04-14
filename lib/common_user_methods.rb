module CommonUserMethods
  def post_login_actions
    user = User.find(session[:user_id])
    if user.needs_an_edit?
      redirect_to user_url(:action => 'edit',:id => user )
    else
      return_to_original_url
    end
    flash[:confirm] ||= "You have been logged in."
    user.update_attribute :last_login, Time.now
  end
  
  def original_url
    original_url = session["return_to"] || list_url(:id => User.find(session[:user_id]).personal_list )
    session["return_to"] = nil
    return original_url
  end
end
