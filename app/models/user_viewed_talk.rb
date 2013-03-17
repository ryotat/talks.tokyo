class UserViewedTalk < ActiveRecord::Base
  attr_accessible :last_seen, :talk, :user
  belongs_to :talk
  belongs_to :user

  validates :last_seen, :talk_id, :user_id, :presence => true

end
