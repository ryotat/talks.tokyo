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
