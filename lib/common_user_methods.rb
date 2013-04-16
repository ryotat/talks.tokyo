module CommonUserMethods
  def post_login_actions
    user = User.find(session[:user_id])
    if user.needs_an_edit?
      redirect_to edit_user_path(user)
    else
      return_to_original_url
    end
    flash[:confirm] ||= "You have been logged in."
    user.update_attribute :last_login, Time.now
  end

  def do_logout
    User.current = nil
    session[:user_id ] = nil
    session["return_to"] = nil
    flash[:confirm] = "You have been logged out."
  end

  def original_url
    original_url = session["return_to"] || list_url(:id => User.find(session[:user_id]).personal_list )
    session["return_to"] = nil
    return original_url
  end
end
