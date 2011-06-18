require 'validators'

class MeantItRel < ActiveRecord::Base
  belongs_to :srcEndPoint, :class_name => "EndPoint"
  belongs_to :dstEndPoint, :class_name => "EndPoint"

  validates :messageType, :presence => true, :meant_it_message_type => true
  validates :status, :presence => true, :status_type => true

  after_initialize :default_values

  private
    def default_values
      self.status||= "active"
    end
end
