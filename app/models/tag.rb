require 'validators'

class Tag < ActiveRecord::Base
  has_many :objRels, :as => "srcObj"
  has_many :objRels, :as => "dstObj"
  has_many :endPointTagRels
  has_many :endPoints, :through => :endPointTagRels, :foreign_key => '"endPoint_id"'
  has_many :meantItMoodTagRels
  has_many :meantItRels, :through => :meantItMoodTagRels

  validates :name, :presence => true, :uniqueness => true
  validates :status, :presence => true, :status_type => true

  after_initialize :default_values

  private
    def default_values
      self.status||= StatusTypeValidator::STATUS_ACTIVE
    end
end
