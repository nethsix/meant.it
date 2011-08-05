require 'validators'
require 'controller_helper'

class MeantItRel < ActiveRecord::Base
  FIRST_INDEX = 1
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
  after_create :check_pii_property_set_threshold

  private
    def default_values
      self.status||= StatusTypeValidator::STATUS_ACTIVE
    end

    def check_pii_property_set_threshold
      if self.message_type == MeantItMessageTypeValidator::MEANT_IT_MESSAGE_LIKE
        logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, self.inspect:#{self.inspect}")
        logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, self.dst_endpoint.inspect:#{self.dst_endpoint.inspect}")
        dst_endpoint_pii = self.dst_endpoint.pii
        if !dst_endpoint_pii.nil?
          if !dst_endpoint_pii.pii_property_set.nil? and !dst_endpoint_pii.pii_property_set.threshold.nil? and !dst_endpoint_pii.pii_value.nil?
            # Count unique
            piis = ControllerHelper.find_pii_by_message_type_uniq_sender_count(dst_endpoint_pii.pii_value, self.message_type)
            if !piis.nil?
              logger.warn("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, why do we have more than one piis with pii_value:#{dst_endpoint_pii.pii_value}, piis.inspect:#{piis.inspect}") if piis.size > 1
              pii_0_mir_count = piis[0].mir_count
              dst_endpoint_pii_pps_threshold = dst_endpoint_pii.pii_property_set.threshold
              logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, pii_0_mir_count:#{pii_0_mir_count}, dst_endpoint_pii_pps_threshold:#{dst_endpoint_pii_pps_threshold}")
              if pii_0_mir_count.to_i >= dst_endpoint_pii_pps_threshold.to_i
                logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, pii_value:#{dst_endpoint_pii.pii_value} met set threshold of #{dst_endpoint_pii.pii_property_set.threshold}")
                # Reget the pii because it will only have partial info
                pii_0 = Pii.find_by_pii_value(piis[0].pii_value)
                # Send email
                UserMailer.threshold_mail(pii_0).deliver
              end # end if pii_0_mir_count.to_i >= dst_endpoint_pii_pps_threshold.to_i
            end # end if !piis.nil?
          end # end if !dst_endpoint_pii.pii_property_set.nil? and  ...
        end # end if dst_endpoint_pii.nil?
      end # end if self.message_type ==  ... MEANT_IT_MESSAGE_LIKE
    end # end def check_pii_property_set_threshold
end
