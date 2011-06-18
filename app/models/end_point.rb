require 'validators'

class EndPoint < ActiveRecord::Base
  has_many :dstMeantItRels, :foreign_key => "dstMeantItRel_id", :class_name => "MeantItRel"
  has_many :dstEndPoints, :through => :dstMeantItRels, :source => :dstEndPoint
  has_many :srcMeantItRels, :foreign_key => "srcMeantItRel_id", :class_name => "MeantItRel"
  has_many :srcEndPoints, :through => :srcMeantItRels, :source => :srcEndPoint
  has_one :creatorEndPoint, :foreign_key => "createEndPoint_id", :class_name => "EndPoint"
  has_one :pii
  has_many :objRels, :as => "srcObj"
  has_many :objRels, :as => "dstObj"
  has_many :endPointTagRels
  has_many :tags, :through => :endPointTagRels
  has_many :entityEndPointRels
  has_many :entities, :through => :entityEndPointRels

  belongs_to :creatorEndPoint, :class_name => "EndPoint"

  validates :nick, :presence => true
  validates :startTime, :presence => true
  validates :status, :presence => true, :status_type => true

  after_initialize :default_values

  private
    def default_values
      self.status||= "active"
    end
end
