# == Schema Information
# Schema version: 20130607030122
#
# Table name: list_users
#
#  list_id :integer
#  user_id :integer
#  id      :integer          not null, primary key
#

class ListUser < ActiveRecord::Base
  attr_protected
  belongs_to :user
  belongs_to :list
  
  def user_email=( email_address )
    self.user = User.find_or_create_by_email(email_address)
  end
  
  def user_email
    return "" unless user
    user.email
  end
  
end
