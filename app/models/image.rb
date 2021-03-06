# == Schema Information
# Schema version: 20130607030122
#
# Table name: images
#
#  id         :integer          not null, primary key
#  data       :binary(16777215)
#  created_at :datetime
#

class Image < ActiveRecord::Base
  attr_accessible :data
  validates_length_of :data, :within => 1 ... 1.megabytes
  has_one :user
  has_one :talk
  has_one :list
  before_destroy :remove_association

  def data=(file)
    if file.size > 0 && file.size < 1.megabyte
      img = Magick::Image.from_blob(file.read)[0]
      img.format = 'PNG'
      self[:data] = img.to_blob
    end
    GC.start
  end
  
  def to_magick( geometry = nil )
    return nil unless data
    magick = Magick::Image.from_blob(data)[0]
    magick.change_geometry!(geometry) { |cols, rows, image| image.resize!(cols, rows) } if geometry
    GC.start
    magick
  end

  def remove_association
    parent = user || talk || list
    parent.image_id = nil
    parent.save
  end
end
