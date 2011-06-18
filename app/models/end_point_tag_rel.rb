require 'validators'

class EndPointTagRel < ActiveRecord::Base
  belongs_to :endPoint
  belongs_to :tag

  validates :status, :presence => true, :status_type => true

  after_initialize :default_values

  private
    def default_values
      self.status||= "active"
    end
end
