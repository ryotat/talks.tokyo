def last_email( n=1 )
  ActionMailer::Base.deliveries.last(n).first
end

def sign_in(user, pass=user.password)
  visit login_path
  fill_in "email", with: user.email
  fill_in "password", with: pass
  click_button "Log in"
end

def sign_out
  visit login_path(:action => "logout")
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

def have_link_to( url )
  have_xpath "//a[@href='%s']"%[url]
end

def create_list(user, name)
  click_link "new list"
  fill_in "list_name", with: name
  click_button "Save"
end

def cleanup
  Talk.find(:all).map { |x| x.destroy }
  User.find(:all).map { |x| x.destroy }
  List.find(:all).map { |x| x.destroy }
  ListUser.find(:all).map { |x| x.destroy }
end

def beginning_of_day
  Time.now.at_beginning_of_day
end

def add_random_talks( list )
  Array(5..10).sample.times.map { FactoryGirl.create(:talk, :series => list) }
  FactoryGirl.create(:talk, :series => list, :start_time => Time.now + 60)
end

def today(t = Time.now)
  t.at_beginning_of_day.strftime('%Y%m%d')
end

def bad_script
  "<script>document.write('<b>I got you</b>');</script>"
end
