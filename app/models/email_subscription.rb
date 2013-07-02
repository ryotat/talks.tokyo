# == Schema Information
# Schema version: 20130607030122
#
# Table name: email_subscriptions
#
#  id      :integer          not null, primary key
#  user_id :integer
#  list_id :integer
#

# Schema as of Sat Mar 18 21:01:28 GMT 2006 (schema version 9)
#
#  id                  :integer(11)   not null
#  user_id             :integer(11)   
#  list_id             :integer(11)   
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
