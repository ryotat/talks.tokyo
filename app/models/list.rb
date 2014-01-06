# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130607030122
#
# Table name: lists
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  details              :text
#  type                 :string(50)
#  details_filtered     :text
#  ex_directory         :boolean          default(FALSE)
#  old_id               :integer
#  image_id             :integer
#  created_at           :datetime
#  updated_at           :datetime
#  talk_post_password   :string(255)
#  style                :string(255)
#  default_language     :string(255)
#  mailing_list_address :string(255)
#


class CannotRemoveTalk < RuntimeError; end
class CannotAddList < RuntimeError; end


class List < ActiveRecord::Base
  attr_accessible :name, :details, :ex_directory, :image, :default_language, :mailing_list_address, :hue

  validates :mailing_list_address, :format => { :with => /(^$|^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$)/i, :message => " is invalid"  }

  scope :with_mailing_list_address, where("mailing_list_address is not null").where("mailing_list_address != ''")


  after_initialize :default_values
  def default_values
    self.default_language ||= I18n.locale
  end

  
  def List.find_public(*args)
    List.with_scope :find => { :conditions => ["ex_directory = 0 AND (type is null OR type != 'Venue')  AND name != 'Name to be confirmed'"] } do
      List.find(*args)
    end
  end

  def List.random(number_of_lists_to_find = 1, exclude_list_id = 0 )
    List.find_public(:all, :order => 'RAND()', :limit => number_of_lists_to_find, :conditions => ["id != ?",exclude_list_id])
  end
  
  def List.sort_field; 'name' end
  
  include TextileToHtml # To convert details
  include Relatable # To have related lists and talks
  include CleanUtf # To try and prevent any malformed utf getting in
  
  # This is used to find or create from a series name
  # If it finds the list, it checks that the current user can edit it.
  # If the current user cannot edit the list, then a new list is created with that name
  def List.find_or_create_by_name_while_checking_management( new_name )
    existing_lists = List.find_all_by_name( new_name )
    existing_lists.each do |list|
      next unless list.managers.include?(User.current)
      return list
    end
    new_list = List.create :name => new_name
    new_list.managers << User.current
    new_list
  end
  
  # The managers
  has_many :list_users, :dependent => :destroy
  has_many :users, :through => :list_users
  alias :managers :users
  
  # Link tables, can add a 'direct' call to get direct relationships
  has_many :list_talks, :dependent => :destroy, :extend => FindDirectExtension
  has_many :list_lists, :dependent => :destroy, :extend => FindDirectExtension
  has_many :reverse_list_lists, :class_name => 'ListList', :foreign_key => :child_id, :dependent => :destroy, :extend => FindDirectExtension
  has_many :reverse_related_lists, :class_name => "RelatedList", :foreign_key => :list_id, :dependent => :destroy

  
  # Interesting relationships, can add a direct call to get direct relationships 
  has_many :talks, :through => :list_talks, :select => 'DISTINCT talks.*', :extend => FindDirectExtension  
  has_many :children, :through => :list_lists, :select => 'DISTINCT lists.*', :extend => FindDirectExtension  
  has_many :parents, :through => :reverse_list_lists, :source => :list, :select => 'DISTINCT lists.*', :extend => FindDirectExtension
  
  # These are the talks that are directly in the series
  has_many :talks_in_series, :class_name => 'Talk', :foreign_key => 'series_id'
  
  # This is to allow a custom image to be loaded
  include BelongsToImage

  # Validations
  validates_presence_of :name
    
  # Make sure the html stays in sync
  before_save :update_html_for_abstract
  before_save :randomize_color_if_required
  # Make sure the relevant bits of the talks (e.g. whether they are ex-directory) stays in sync
  after_save  :update_talks_in_series
  before_destroy :destroy_talks_in_series
  
  def destroy_talks_in_series
    talks_in_series.each do |t|
      t.destroy
    end
  end
  
  def update_talks_in_series
    talks_in_series(true).each do |talk|
      if talk.ex_directory != self.ex_directory? && !talk.canceled?
        talk.ex_directory = self.ex_directory?
        talk.save
      end
    end
  end
  
  def add( object )
    case object
    when List;
      raise CannotAddList, "Cannot add ‘#{object.name}’ to itself. " if object == self
#      raise CannotAddList, "Cannot add &#145;#{object.name}&#146; to &#145;#{self.name}&#146; as it would create a loop. " if object.children.include?( self )
      list_lists.create(:child => object).valid?
    when Talk
      list_talks.create(:talk => object).valid?
    end
  end
  
  def remove( object, prevent_from_talk_or_series = true )
    case object
    when List; list_lists.find_by_child_id_and_dependency( object.id, nil ).destroy
    when Talk
      if prevent_from_talk_or_series
        raise CannotRemoveTalk, "Cannot remove ‘#{object.name}’ from its series. " if object.series == self
        raise CannotRemoveTalk, "Cannot remove ‘#{object.name}’ from its venue. " if object.venue == self
      end
      link = list_talks.find_by_talk_id_and_dependency( object.id, nil )
      link.destroy if link
    end
  end
  
  def editable?
    return false unless User.current
    User.current.administrator? or users.include?( User.current )
  end
    
  # This is used to transform the textile in abstract into redcloth
  def update_html_for_abstract
    return unless details
    self.details_filtered = textile_to_html( details )
  end
   
   def to_s; name end

   def authenticate_talk_post_password(password)
     talk_post_password == password
   end

   def randomize_talk_post_password
     chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
     random_password = Array.new(20).map { chars[rand(chars.size-1)] }.join
     self.talk_post_password = random_password
     self.save!
   end

   def id_all(ids = nil)
     if ids
       ids << self.id
     else
       ids = [self.id]
     end
     self.children.each do |list|
       unless ids.include?(list.id)
         ids = list.id_all(ids)
       end
     end
     return ids
   end

   def randomize_color
     self.hue = rand(360)
   end

   def randomize_color_if_required
     if self.style.nil?
       randomize_color
     end
   end

   def hue
     if style
       r=style[1,2].to_i(16); g=style[3,2].to_i(16); b=style[5,2].to_i(16)
       m,ix=[r,g,b].each_with_index.max
       w=([r,g,b].max-[r,g,b].min).to_f
       hue = [(g-b)/w, (b-r)/w+2, (r-g)/w+4].map { |x| (x*60)%360 }
       return hue[ix].to_i
     else
       return rand(360)
     end
   end

   def hue=(h)
     h=h.to_f
     s=0.3; v=240.0
     rgb = [(h+180)%360-180, (h-120+180)%360-180, (h+120+180)%360-180].map { |x| x.abs > 120 ? v*(1-s) : (x.abs > 60 ? v*(1-(x.abs/60-1)*s) : v)  }
     self.style = "#%x%x%x"%rgb
   end

   def personal?
     ex_directory? && managers.length == 1 && managers[0].personal_list==self
   end

   def as_json(options = {})
     super options.merge({:only => [:name, :details_filtered], 
                         :methods => [:start_time, :end_time]})
   end

   def start_time
     talks.map(&:start_time).min
   end

   def end_time
     talks.map(&:end_time).max
   end
end

# This is only used for legacy / imported lists
class Series < List; end
