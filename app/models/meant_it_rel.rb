require 'validators'

class MeantItRel < ActiveRecord::Base
  has_many :meantItMoodTagRels
  has_many :tags, :through => :meantItMoodTagRels
#  belongs_to :srcEndPoint, :class_name => "EndPoint"
  belongs_to :src_endpoint, :class_name => "EndPoint"
#  belongs_to :dstEndPoint, :class_name => "EndPoint"
  belongs_to :dst_endpoint, :class_name => "EndPoint"
  belongs_to :inbound_email

#  validates :messageType, :presence => true, :meant_it_message_type => true
  validates :message_type, :presence => true, :meant_it_message_type => true
  validates :status, :presence => true, :status_type => true

  after_initialize :default_values

  private
    def default_values
      self.status||= StatusTypeValidator::STATUS_ACTIVE
    end
end
