# == Schema Information
# Schema version: 20130607030122
#
# Table name: user_viewed_talks
#
#  id        :integer          not null, primary key
#  user_id   :integer
#  talk_id   :integer
#  last_seen :datetime
#

class UserViewedTalk < ActiveRecord::Base
  attr_accessible :last_seen, :talk, :user
  belongs_to :talk
  belongs_to :user

  validates :last_seen, :talk_id, :user_id, :presence => true

end
