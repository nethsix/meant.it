require 'validators'

class EndPoint < ActiveRecord::Base
#  alias_attribute :end_point_id, :endPoint_id
#  alias_attribute "endPoint_id" "end_point_id"

  has_many :dstMeantItRels, :foreign_key => "dst_endpoint_id", :class_name => "MeantItRel"
#  has_many :dstEndPoints, :through => :dstMeantItRels, :source => :dstEndPoint
  has_many :dstEndPoints, :through => :dstMeantItRels, :source => :dst_endpoint
  has_many :srcMeantItRels, :foreign_key => "src_endpoint_id", :class_name => "MeantItRel"
#  has_many :srcEndPoints, :through => :srcMeantItRels, :source => :srcEndPoint
  has_many :srcEndPoints, :through => :srcMeantItRels, :source => :src_endpoint
#  has_one :creatorEndPoint, :foreign_key => "createEndPoint_id", :class_name => "EndPoint"
  has_one :creatorEndPoint, :foreign_key => "creator_endoint_id", :class_name => "EndPoint"
#  has_one :pii, :foreign_key => '"endPoint_id"'
  has_one :pii, :foreign_key => "endpoint_id"
#  has_many :objRels, :as => "srcObj"
  has_many :objRels, :as => "srcobj"
#  has_many :objRels, :as => "dstObj"
  has_many :objRels, :as => "dstobj"
#  has_many :endPointTagRels, :foreign_key => '"endPoint_id"', :class_name => "EndPointTagRel"
  has_many :endPointTagRels, :foreign_key => "endpoint_id", :class_name => "EndPointTagRel"
  has_many :tags, :through => :endPointTagRels
#  has_many :entityEndPointRels, :foreign_key => '"endPoint_id"'
  has_many :entityEndPointRels, :foreign_key => "endpoint_id"
  has_many :entities, :through => :entityEndPointRels

  belongs_to :creatorEndPoint, :class_name => "EndPoint"

  validates :nick, :presence => true
#  validates :startTime, :presence => true
  validates :start_time, :presence => true
  validates :status, :presence => true, :status_type => true

  after_initialize :default_values

  private
    def default_values
      self.status||= "active"
    end
end
