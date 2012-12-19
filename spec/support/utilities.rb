def last_email
  ActionMailer::Base.deliveries.last
end

def sign_in(user, pass=user.password)
  visit login_path
  fill_in "email", with: user.email
  fill_in "password", with: pass
  click_button "Log in"
end

def new_posted_talk_url_for( list )
  new_posted_talk_url(:list_id => list.id, :key => list.talk_post_password)
end

def find_or_create(klass, name, *options)
  klass.where('name LIKE ?', "%#{name}%")[0] || FactoryGirl.create(name, *options)
end

def show_404
  have_content("The page you were looking for doesn't exist")
end

def show_403
  have_content("Sorry, you do not have permission for that action")
end

def create_list(user, name)
  click_link "Create a new list"
  fill_in "list_name", with: name
  click_button "Save"
end

def cleanup
  Talk.find(:all).map { |x| x.destroy }
  User.find(:all).map { |x| x.destroy }
  List.find(:all).map { |x| x.destroy }
  ListUser.find(:all).map { |x| x.destroy }
end
