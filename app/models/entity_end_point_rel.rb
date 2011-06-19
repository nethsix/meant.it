require 'validators'

class EntityEndPointRel < ActiveRecord::Base
  belongs_to :endPoint, :class_name => "EndPoint", :foreign_key => '"endPoint_id"'
  belongs_to :entity

  validates :verificationType, :presence => true, :verification_type => true
  validates :status, :presence => true, :status_type => true

  after_initialize :default_values

  private
    def default_values
      self.status||= "active"
    end
end
