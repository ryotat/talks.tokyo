# == Schema Information
# Schema version: 20130607030122
#
# Table name: tickles
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  about_id        :integer
#  about_type      :string(255)
#  sender_id       :integer
#  recipient_email :text
#  sender_email    :string(255)
#  sender_name     :string(255)
#  sender_ip       :string(255)
#

# This keeps a track of the 'tell-a-friend' type requests
class Tickle < ActiveRecord::Base
  attr_accessible :about_id, :about_type, :recipient_email, :sender, :sender_ip, :subject, :body
  belongs_to :about, :polymorphic => true
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  
  before_validation :update_sender_details_from_sender_object
  after_save :send_tickle_to_recipient
  
  validates_format_of :sender_email, :with => /.*?@.*?\..*/
  validates_format_of :recipient_email, :with => /.*?@.*?\..*/
  validates_length_of :sender_name, :minimum => 2
  
  def validate
    if Tickle.find_by_recipient_email_and_about_id_and_about_type(recipient_email,about_id,about_type)
      errors.add(:recipient_email,"has already been sent a message about this.")
    end
    if sender_ip && Tickle.find(:all,:conditions => ['created_at > ? AND sender_ip = ?',1.hour.ago, sender_ip] ).size >= 10
      errors.add(:sender_ip,"has already sent more than 10 messages in the past hour")
    end
  end

  def send_tickle_to_recipient
    add_abuse
    case about
    when Talk; Mailer.talk_tickle( self ).deliver
    when List; Mailer.list_tickle( self ).deliver
    end
  end
  
  def update_sender_details_from_sender_object
    return true unless sender
    self.sender_email = sender.email
    self.sender_name = sender.name
    true
  end

  attr_accessor :body, :subject
  
  def set_default_subject_body
    update_sender_details_from_sender_object
    unless @mail
      case about
      when Talk; @mail = Mailer.talk_tickle( self )
      when List; @mail = Mailer.list_tickle( self )
      end
    end
    @subject=@mail.subject
    @body=@mail.body
  end

  def add_abuse
    self.body += "\n\n"+I18n.t(:tickle_abuse) % [WEBMASTER, self.id]
  end
end
