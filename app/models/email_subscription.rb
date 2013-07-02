# == Schema Information
# Schema version: 20130607030122
#
# Table name: email_subscriptions
#
#  id      :integer          not null, primary key
#  user_id :integer
#  list_id :integer
#

class EmailSubscription < ActiveRecord::Base
  attr_protected
  belongs_to :user
  belongs_to :list

  validates_presence_of :user
  validates_presence_of :list
  
  # For security
   def editable?
     return false unless User.current
     User.current.administrator? or
     (user == User.current )
   end
end
