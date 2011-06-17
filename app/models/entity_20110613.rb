require 'validators'

class Entity < ActiveRecord::Base

  has_many :entityEndPointRels
  has_many :endPoints, :through => entityEndPointRels
  validates :propertyDocument_id, :presence => true, :uniqueness => true, :propertyDocument_id_foreign_key => true
  validates :status, :presence => true, :status_type => true

end
