# Schema as of Sat Mar 18 21:01:28 GMT 2006 (schema version 9)
#
#  id                  :integer(11)   not null
#  name                :string(255)   
#  details             :text          
#  type                :string(50)    
#  details_filtered    :text          
#  image               :string(255)   
#

class CannotRemoveTalk < RuntimeError; end
class CannotAddList < RuntimeError; end


class List < ActiveRecord::Base
  attr_accessible :name, :details, :ex_directory, :image
  
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
  has_many :list_users
  has_many :users, :through => :list_users
  alias :managers :users
  
  # Link tables, can add a 'direct' call to get direct relationships
  has_many :list_talks, :dependent => :destroy, :extend => FindDirectExtension
  has_many :list_lists, :dependent => :destroy, :extend => FindDirectExtension
  has_many :reverse_list_lists, :class_name => 'ListList', :foreign_key => :child_id, :dependent => :destroy, :extend => FindDirectExtension
  
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
  
  def sort_of_delete
    list_users.clear
    self.ex_directory = true
    self.save
    
    parents.direct.each do |parent|
      parent.remove( self )
    end
    
    talks_in_series(true).each do |talk|
      Talk.find(talk.id).sort_of_delete
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
      raise CannotAddList, "Cannot add &#145;#{object.name}&#146; to itself. " if object == self
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
        raise CannotRemoveTalk, "Cannot remove &#145;#{object.name}&#146; from its series. " if object.series == self
        raise CannotRemoveTalk, "Cannot remove &#145;#{object.name}&#146; from its venue. " if object.venue == self
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
     h=rand(360).to_f-180; s=30.0/100; v=240.0
     rgb = [h, (h-120+180)%360-180, (h+120+180)%360-180].map { |x| x.abs > 120 ? v*(1-s) : (x.abs > 60 ? v*(1-(x.abs/60-1)*s) : v)  }
     self.style = "#%x%x%x"%rgb
   end

   def randomize_color_if_required
     if self.style.nil?
       randomize_color
     end
   end

end

# This is only used for legacy / imported lists
class Series < List; end
