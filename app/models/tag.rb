require 'validators'

class Tag < ActiveRecord::Base
  has_many :objRels, :as => "srcObj"
  has_many :objRels, :as => "dstObj"
  has_many :endPointTagRels
  has_many :endPoints, :through => :endPointTagRels

  validates :name, :presence => true
  validates :status, :presence => true, :status_type => true
end
