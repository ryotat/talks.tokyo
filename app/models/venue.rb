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

# This makes it easy to pick out venues 
class Venue < List; 

  def Venue.find_public(*args)
    Venue.with_scope :find => { :conditions => ["ex_directory = 0"] } do
      Venue.find(*args)
    end
  end  

  def Venue.find_or_create_by_name_while_checking_management( new_name )
    List.find_or_create_by_name_while_checking_management( new_name, Venue )
  end
end
