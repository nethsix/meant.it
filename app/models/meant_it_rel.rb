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
  belongs_to :email_bill_entry

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
#20110807            piis = ControllerHelper.find_pii_by_message_type_uniq_sender_count(dst_endpoint_pii.pii_value, self.message_type)
#20110813            mirs = ControllerHelper.get_likers_by_email_bill_entry_id(dst_endpoint_pii.pii_value)
            mirs, start_bill_date, end_bill_date = ControllerHelper.get_latest_likers_by_pii_value(dst_endpoint_pii.pii_value)
#20110807            if !piis.nil?
            if !mirs.nil?
#20110807              logger.warn("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, why do we have more than one piis with pii_value:#{dst_endpoint_pii.pii_value}, piis.inspect:#{piis.inspect}") if piis.size > 1
#20110807              pii_0_mir_count = piis[0].mir_count
              dst_endpoint_pii_pps_threshold = dst_endpoint_pii.pii_property_set.threshold
#20110807              logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, pii_0_mir_count:#{pii_0_mir_count}, dst_endpoint_pii_pps_threshold:#{dst_endpoint_pii_pps_threshold}")
             logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, mirs.size:#{mirs.size}, dst_endpoint_pii_pps_threshold:#{dst_endpoint_pii_pps_threshold}")
#20110807              if pii_0_mir_count.to_i >= dst_endpoint_pii_pps_threshold.to_i
              if mirs.size.to_i >= dst_endpoint_pii_pps_threshold.to_i
                # Create billing
                entity_no_match_arr = dst_endpoint_pii.pii_value.match(/(\d+)#{Constants::ENTITY_DOMAIN_MARKER}/)
                entity_no = entity_no_match_arr[1] if !entity_no_match_arr.nil?
                logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, entity_no:#{entity_no}")
                if !entity_no.nil? and !entity_no.empty?
                  entity = Entity.find(entity_no)
                  if entity.nil?
                    logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, unable to bill since no entity found from pii_value:#{pii_value}")
                    raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, unable to bill since no entity found from pii_value:#{pii_value}"
                  end # end if entity.nil?
                  pps = dst_endpoint_pii.pii_property_set
                  # Create email bill entry for each mir 
                  if entity.email_bill.nil?
                    entity.email_bill = EmailBill.create 
                  end # end if email_bill.nil?
                  email_bill = entity.email_bill
                  # Link every bill entry to entity email bill and pii_property_set
                  email_bill_entry = email_bill.email_bill_entries.create(:pii_property_set_id => pps.id)
                  email_bill_entry.ready_date = Time.now
                  mirs.each { |mir_elem|
                    mir_where_1 = MeantItRel.where(:src_endpoint_id => mir_elem.src_endpoint_id).where(:dst_endpoint_id, self.dst_endpoint.id).where(:message_type => MeantItMessageTypeValidator::MEANT_IT_MESSAGE_LIKE)
                    option_str_all = ControllerHelper.get_date_option_str(start_bill_date, end_bill_date, true)
                    if !option_str_all.nil?
                      full_mirs = mir_where_1.where(option_str_all)
                    else
                      full_mirs = mir_where_1
                    end # end if !option_str_all.nil?
                    if full_mirs.empty?
                    end # end if full_mirs.empty?
                    full_mir = full_mirs[full_mirs.size-1]
                    email_bill_entry.meant_it_rels << full_mir
#20110814                    full_ep = EndPoint.find(mir_elem.src_endpoint_id)
#20110814                    email_bill_entry.end_points << full_ep
                  } # end mir.each  ...
                  unless email_bill_entry.save
                    logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, could not save mirs to email_bill_entry.inspect:#{email_bill_entry.inspect}")
                    raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, could not save mirs to email_bill_entry.inspect:#{email_bill_entry.inspect}"
                  end # end unless email_bill_entry.save
                  logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, pii_value:#{dst_endpoint_pii.pii_value} met set threshold of #{dst_endpoint_pii.pii_property_set.threshold}")
                  # If onetime, then set status to LIKER_STATUS_BILLED
                  if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
                    pps.status = StatusTypeValidator::STATUS_INACTIVE
                    unless pps.save
                      logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, failed to change pii_value:#{pii_value} pps status to #{StatusTypeValidator::STATUS_INACTIVE}")
                      raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, failed to change pii_value:#{pii_value} pps status to #{StatusTypeValidator::STATUS_ACTIVE}"
                    end # end unless pps.save
                  elsif pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_RECUR
                    # Don't need to do anything
                  else
                    logger.error("#{File.basename(__FILE__)}:#{self.class}:check_pii_property_set_threshold, pps.threshold_type:#{pps.threshold_type} not supported by billing system")
                    raise Exception, "#{File.basename(__FILE__)}:#{self.class}:check_pii_property_set_threshold, pps.threshold_type:#{pps.threshold_type} not supported by billing system"
                  end # end if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
                  # Reget the pii because it will only have partial info
                  pii_0 = Pii.find_by_pii_value(dst_endpoint_pii.pii_value)
                  unless dst_endpoint_pii.pii_property_set.save
                    logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, setting dst_endpoint_pii.pii_property_set.ready to true failed, dst_endpoint_pii.pii_property_set.errors.inspect:#{dst_endpoint_pii.pii_property_set.errors.inspect}")
                    raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, setting dst_endpoint_pii.pii_property_set.ready to true failed, dst_endpoint_pii.pii_property_set.errors.inspect:#{dst_endpoint_pii.pii_property_set.errors.inspect}"
                  end # end unless dst_endpoint_pii.pii_property_set.save
                  # Send email
                  UserMailer.threshold_mail(pii_0).deliver
                else
                  logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, no entity_no for pii_value:#{pii_value} so cannot attach billing")
                  raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold, no entity_no for pii_value:#{pii_value} so cannot attach billing"
                end # end if !entity_no.nil? and !entity_no.empty?

              end # end if mirs.size.to_i >= dst_endpoint_pii_pps_threshold.to_i
            end # end if !mirs.nil?
          end # end if !dst_endpoint_pii.pii_property_set.nil? and  ...
        end # end if dst_endpoint_pii.nil?
      end # end if self.message_type ==  ... MEANT_IT_MESSAGE_LIKE
    end # end def check_pii_property_set_threshold
end
