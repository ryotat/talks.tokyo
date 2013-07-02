# == Schema Information
# Schema version: 20130607030122
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  email              :string(255)
#  name               :string(255)
#  affiliation        :string(75)
#  administrator      :integer          default(0), not null
#  old_id             :integer
#  last_login         :datetime
#  crsid              :string(255)
#  image_id           :integer
#  name_in_sort_order :string(255)
#  ex_directory       :boolean          default(TRUE)
#  created_at         :time
#  updated_at         :time
#  password_digest    :string(255)
#  suspended          :boolean
#  locale             :string(255)
#

require 'bcrypt'

class User < ActiveRecord::Base
  attr_protected :password_digest, :administrator
  has_secure_password

  validates :email, :presence => true, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => " is invalid"  }

  validates_uniqueness_of :email, :message => 'address is already registered on the system'
  validate :existing_password_match, :on => :update, :unless => "existing_password.nil?"

  after_initialize :default_values
  def default_values
    self.locale ||= I18n.locale
  end

  # This is used as an easier way of accessing who is the current user
  def User.current=(u)
    Thread.current[:user] = u unless u && u.suspended?
  end
  
  def User.current
    u=Thread.current[:user]
    return u unless u && u.suspended?
  end
  
  def User.search(search_term)
    return [] unless search_term && !search_term.empty?
    User.find_public(:all, :conditions => ["(name LIKE :search OR affiliation LIKE :search OR email LIKE :search)",{:search => "%#{search_term.strip}%"}], :order => 'name ASC' )
  end
  
  def User.find_public(*args)
    User.with_scope :find => { :conditions => ["ex_directory = 0"] } do
      User.find(*args)
    end
  end
  
  def User.sort_field; 'name_in_sort_order' end
  
  def User.find_or_create_by_crsid( crsid )
    false
  end


  # This should come before has_many :list_users, dependent: :destroy
  before_destroy { personal_list.destroy }
  
  # Lists that the user is mailed about
  has_many :email_subscriptions, dependent: :destroy
  
  # Lists that this user manages
  has_many :list_users, dependent: :destroy
  has_many :lists, :through => :list_users
  
  # Talks that this user speaks on
  has_many :talks, :foreign_key => 'speaker_id', :conditions => "ex_directory != 1", :order => 'start_time DESC'
  
  # Talks that this user organises
  has_many :talks_organised, :class_name => "Talk", :foreign_key => 'organiser_id', :conditions => "ex_directory != 1", :order => 'start_time DESC'

  # Talks that this user has seen
  has_many :user_viewed_talks, dependent: :destroy
  has_many :recently_viewed_talks, :through => :user_viewed_talks, :source => "talk", :conditions => "user_viewed_talks.last_seen > '#{1.month.ago}'", :order => 'user_viewed_talks.last_seen DESC'
    
  # Life cycle actions
  before_save :update_crsid_from_email
  before_save :update_name_in_sort_order
  before_create  # :randomize_password
  after_create :create_personal_list
  after_create # :send_password_if_required
  
  # Try and prevent xss attacks
  include CleanUtf # To try and prevent any malformed utf getting in
  
  # Has a connected image
  include BelongsToImage
  
  def editable?
    return false unless User.current
    ( User.current == self ) or ( User.current.administrator? )
  end
  
  def update_crsid_from_email
    return unless email =~ /^([a-z0-9]+)@cam.ac.uk$/i
    self.crsid = $1
  end
  
  def update_name_in_sort_order
    if name =~ /^\s*((.*) )?(.*)\s*$/
      self.name_in_sort_order = $2 ? "#{$3}, #{$2}" : $3
    else
      self.name_in_sort_order = ""
    end
  end
  
  def self.update_ex_directory_status
    User.find(:all).each { |u| u.update_ex_directory_status }
  end
  
  def update_ex_directory_status
    new_status = lists.find(:all,:conditions => ['ex_directory = 0']).empty? && talks.empty? && talks_organised.empty?
    update_attribute(:ex_directory,new_status) unless self.ex_directory? == new_status
    new_status
  end
  
  # Only accept new passwords when some confirmation is done
  attr_accessor :password_confirmation
  attr_accessor :existing_password
  attr_accessor :old_password

  def password=(unencrypted_password)
    unless unencrypted_password.blank?
      if !new_record?
        self.old_password = BCrypt::Password.new(password_digest)
      end
      @password = unencrypted_password
      self.password_digest = BCrypt::Password.create(unencrypted_password)
    end
  end

  def existing_password_match
    errors.add(:existing_password,"must match your existing password.") unless old_password==existing_password
  end
  
  # ten digit password
  def randomize_password( size = 10 )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpassword = ""
    1.upto(size) { |i| newpassword << chars[rand(chars.size-1)] }
    self.password= newpassword
    self.save!
    return newpassword # return unencrypted password
  end
  
  # After creating a user, create their personal list
  def create_personal_list
    list_name = 
      if self.name; "#{self.name}'s list"
      elsif self.crsid; "#{self.crsid}'s list"
      else; "Your personal list"
    end
    list = List.create! :name => list_name, :details => "A personal list of talks.", :ex_directory => true
    self.lists << list
  end

  # After creating a user, send them an e-mail with their password if this is set
  attr_accessor :send_email
  
  def send_password_if_required
    send_password if send_email
  end
  
  def send_password
    newpassword = randomize_password
    Mailer.password( self, newpassword ).deliver
  end
  
  def personal_list
    lists.first
  end
  
  def only_personal_list?
    (lists.size == 1)
  end
  
  def send_emails_about_personal_list
    EmailSubscription.find_by_list_id_and_user_id( personal_list, id ) ? true : false
  end
  
  def send_emails_about_personal_list=(send_email)
    if send_email == '1' && !send_emails_about_personal_list
      email_subscriptions.create :list => personal_list
    elsif send_email == '0' && send_emails_about_personal_list
      EmailSubscription.find_by_list_id_and_user_id( personal_list, id ).destroy
    end
  end
  
  # Subscribe by email to a lsit
  def subscribe_to_list( list )
    email_subscriptions.create :list => list
  end
  
  def has_added_to_list?( thing )
    case thing
    when List
      lists.detect { |users_list| users_list.children.direct.include?( thing ) }
    when Talk
      lists.detect { |users_list| users_list.talks.direct.include?( thing )}
    end
  end
  
  # This is used upon login to check whether the user should be asked to fill in more detail
  def needs_an_edit?
    return last_login ? false : true
  end

  def just_seen( talk )
    link = user_viewed_talks.find_by_talk_id(talk.id)
    if link
      link.last_seen = Time.now
      link.save
    else
      user_viewed_talks.create(:last_seen => Time.now, :talk => talk)
    end
  end

  def suspend
    self.suspended = true
    self.save
  end

  def unsuspend
    self.suspended = false
    self.save
  end
end
