require 'validators'

class EndPointTagRel < ActiveRecord::Base
#  belongs_to :endPoint, :class_name => "EndPoint", :foreign_key => '"endPoint_id"'
  belongs_to :endPoint, :class_name => "EndPoint", :foreign_key => "endpoint_id"
  belongs_to :tag

  validates :status, :presence => true, :status_type => true

  after_initialize :default_values

  private
    def default_values
      self.status||= "active"
    end
end
