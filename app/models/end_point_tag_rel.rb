require 'validators'

class EndPointTagRel < ActiveRecord::Base
  belongs_to :endPoint
  belongs_to :tag

  validates :status, :presence => true, :status_type => true
end
