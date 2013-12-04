shared_context "for an administrator", :user => :admin do
  let(:admin_user) { FactoryGirl.create(:user, :administrator => true) }
  before do
    sign_in admin_user
  end
end

shared_context "for a non-organizer", :user => :visitor do
  let(:non_admin_user) { FactoryGirl.create(:user) }
  before do
    sign_in non_admin_user
  end
end

shared_context "when not logged in", :user => :none do
  before do
    sign_out
  end
end

shared_examples "association_dialog" do
  it { should have_content "Which lists would you like to include" }
end

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

def new_posted_talk_path_for( list_id )
  list = List.find(list_id)
  new_posted_talk_path(:list_id => list.id, :key => list.talk_post_password)
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
  Time.zone.now.at_beginning_of_day
end

def create_random_lists( n )
  n.times.map { FactoryGirl.create(:list) }
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

def path_of(selector)
  uri = URI.parse(find(selector)[:href])
  "#{uri.path}?#{uri.query}"
end

def current_full_path
  uri = URI.parse(current_url)
  if uri.query
    "#{uri.path}?#{uri.query}"
  else
    uri.path
  end
end


def open_talk_associations(talk)
  visit talk_path(talk)
  click_link 'Add/Remove from your lists'
#  wait_until { page.has_content? "Which lists would you like to include" }
end

def open_list_associations(list)
  visit list_path(list)
  click_link 'Add/Remove from your lists'
#  wait_until { page.has_content? "Which lists would you like to include" }
end

def send_tickle(email)
  click_link "Tell a friend"
  wait_until { page.has_content? "Tell a friend about this" }
  fill_in 'tickle_recipient_email', :with => email
  click_button 'Send e-mail'
end

def without_q(str)
  return str[-1]=="?" ? str[0..-2] : str
end

def dropdown_new_talk(list)
  within('div.nav-collapse li.dropdown') { click_link "new talk" }
  within('div.nav-collapse ul.dropdown-menu') { click_link list.name }
end
