# == Schema Information
# Schema version: 20130607030122
#
# Table name: related_talks
#
#  id           :integer          not null, primary key
#  related_id   :integer
#  related_type :string(255)
#  talk_id      :integer
#  score        :float
#

class RelatedTalk < ActiveRecord::Base
  attr_protected
  belongs_to :related, :polymorphic => true
  belongs_to :talk
  delegate :title, :to => :talk

  def self.update_all_lists_and_talks
    List.find(:all).each { |list| self.create_for(list) }
    Talk.find(:all).each { |talk| self.create_for(talk) }
  end
  
  def self.create_for( owner )
    owner.related_talks.clear
    Talk.random_and_in_the_future(6,owner.id).each do |talk|
        owner.related_talks.create :talk => talk
    end
  end
end
