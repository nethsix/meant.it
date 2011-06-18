require 'validators'

class Pii < ActiveRecord::Base
  belongs_to :endPoint

  validates :piiType, :presence => true, :pii_type => true
  validates :piiValue, :presence => true
  validates :status, :presence => true, :status_type => true

  after_initialize :default_values

  private
    def default_values
      self.status||= "active"
    end
end
