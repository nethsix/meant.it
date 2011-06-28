require 'validators'

class Pii < ActiveRecord::Base
#20110628a  belongs_to :endPoint, :class_name => "EndPoint", :foreign_key => "endpoint_id"
  has_many :endPoints, :class_name => "EndPoint"

  validates :pii_type, :presence => true, :pii_type => true
  validates :pii_value, :presence => true
  validates :status, :presence => true, :status_type => true

  after_initialize :default_values

  private
    def default_values
      self.status||= StatusTypeValidator::STATUS_ACTIVE
    end
end
