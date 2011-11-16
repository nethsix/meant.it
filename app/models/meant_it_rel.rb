require 'validators'
require 'controller_helper'

class MeantItRel < ActiveRecord::Base
  FIRST_INDEX = 1
  # If a sender sends another request for the same pii, use
  # the newer one
  OVERRIDE_MIR = true

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
#20111106  after_create :check_pii_property_set_threshold
  after_create :check_pii_property_set_threshold_v2

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
                  pii_dst_endpoints = dst_endpoint_pii.endPoints.collect { |ep_elem| ep_elem.id }
                  mirs.each { |mir_elem|
                    mir_where_1 = MeantItRel.where(:src_endpoint_id => mir_elem.src_endpoint_id).where(:dst_endpoint_id => pii_dst_endpoints).where(:message_type => MeantItMessageTypeValidator::MEANT_IT_MESSAGE_LIKE)
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

    # +:str:+:: the String containing values, e.g., currency or unit
    # +:result_init:+:: the value that we will add to
    # +:result_init_currency:+:: the currency +result_init+ is in
    # +:value_type:+:: whether we use the +str+ value or just count the entry as 1, depends on this
    def add_value_by_value_type(str, value_type, result_init=nil, result_init_currency=nil, logtag=nil)
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:add_value_by_value_type, str:#{str}, result_init:#{result_init}, result_init_currency:#{result_init_currency}, value_type:#{value_type}")
      result = nil
      if value_type == ValueTypeValidator::VALUE_TYPE_VALUE_UNIQ or value_type == ValueTypeValidator::VALUE_TYPE_VALUE
        # Add value
        if result_init.nil?
          sum_str = "#{str}"
        else
          sum_str = "#{str} #{result_init_currency}#{result_init}"
        end # end if result_init.nil?
        result = ControllerHelper.sum_currency_in_str(sum_str, 0)
      else
        # Add count
        if result_init.nil?
          result = 1
        else
          result = result_init + 1
        end # end if result_init.nil?
      end # end if value_type == ValueTypeValidator::VALUE_TYPE_VALUE_UNIQ or value_type == ValueTypeValidator::VALUE_TYPE_VALUE
      result
    end # end def add_value_by_value_type

    def check_pii_property_set_threshold_v2
      if self.message_type == MeantItMessageTypeValidator::MEANT_IT_MESSAGE_LIKE
        logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, self.inspect:#{self.inspect}")
        logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, self.dst_endpoint.inspect:#{self.dst_endpoint.inspect}")
        dst_endpoint_pii = self.dst_endpoint.pii
        logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, dst_endpoint_pii.inspect:#{dst_endpoint_pii.inspect}")
        orig_msg = ControllerHelper.get_text_from_inbound_email(inbound_email)
        if ControllerHelper.sellable_pii(dst_endpoint_pii)
          entity_no_match_arr = ControllerHelper.auto_entity_domain?(dst_endpoint_pii.pii_value)
          entity_no = entity_no_match_arr[1]
          logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, entity_no:#{entity_no}")
          entity = Entity.find(entity_no)
          if entity.nil?
            logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, unable to bill since no entity found from pii_value:#{pii_value}")
            raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, unable to bill since no entity found from pii_value:#{pii_value}"
          end # end if entity.nil?
          if !dst_endpoint_pii.pii_property_set.nil? and !dst_endpoint_pii.pii_property_set.threshold.nil? and !dst_endpoint_pii.pii_value.nil?
            logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, dst_endpoint_pii.pii_property_set.inspect:#{dst_endpoint_pii.pii_property_set.inspect}")
            entity_no = ControllerHelper.get_entity_no_from_pii(dst_endpoint_pii)
            dst_endpoint_pii_pps_value_type = dst_endpoint_pii.pii_property_set.value_type
            logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, dst_endpoint_pii_pps_value_type:#{dst_endpoint_pii_pps_value_type}")
            # Check if the src_endpoint already has an entry, if so override
            start_bill_date = ControllerHelper.get_bill_dates_by_pii(dst_endpoint_pii)
            email_bill_entry = nil
            email_bill_entries = dst_endpoint_pii.pii_property_set.email_bill_entries.where("ready_date is NULL and created_at >= '#{start_bill_date}'")
            if email_bill_entries.size > 1
              logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, why are there more than 1 email_bill_entries, email_bill_entries.inspect:#{email_bill_entries.inspect}")
              raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, why are there more than 1 email_bill_entries, email_bill_entries.inspect:#{email_bill_entries.inspect}"
            elsif email_bill_entries.size == 1
              email_bill_entry = email_bill_entries[0]
            end # end if email_bill_entries.size > 1
            logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, retrieved email_bill_entry.inspect:#{email_bill_entry.inspect}")
            logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, retrieved email_bill_entry.inspect:#{email_bill_entry.inspect}")
            if email_bill_entry.nil?
              logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, COND: no email_bill_entry yet!")
              # Create an email_bill_entry
              entity.email_bill = EmailBill.create 
              email_bill = entity.email_bill
              email_bill_entry = email_bill.email_bill_entries.create(:pii_property_set_id => dst_endpoint_pii.pii_property_set.id)
              # Add this mir to email_bill_entry
              email_bill_entry.meant_it_rels << self
              unless email_bill_entry.save
                logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, could not save mir.inspect:#{mir.inspect} to email_bill_entry.inspect:#{email_bill_entry.inspect}")
                raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, could not save mir.inspect:#{mir.inspect} to email_bill_entry.inspect:#{email_bill_entry.inspect}"
              end # end unless email_bill_entry.save
              logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, created email_bill_entry for pii_value:#{dst_endpoint_pii.pii_value} and added self.inspect:#{self.inspect}")
              email_bill_entry_qty_str = add_value_by_value_type(orig_msg, dst_endpoint_pii_pps_value_type)
              logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, email_bill_entry_qty_str:#{email_bill_entry_qty_str}")
              email_bill_entry.currency, email_bill_entry.qty = ControllerHelper.get_currency_code_and_val(email_bill_entry_qty_str)
              logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, created email_bill_entry.inspect:#{email_bill_entry.inspect}")
            elsif dst_endpoint_pii_pps_value_type == ValueTypeValidator::VALUE_TYPE_COUNT_UNIQ or dst_endpoint_pii_pps_value_type == ValueTypeValidator::VALUE_TYPE_VALUE_UNIQ
#20111106              # Count the latest entry for each sender,
#20111106              # i.e., one entry per sender
#20111106              mirs, start_bill_date, end_bill_date = ControllerHelper.get_latest_likers_by_pii_value(dst_endpoint_pii.pii_value, true)
              logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, COND: email_bill_entry.inspect:#{email_bill_entry.inspect}, dst_endpoint_pii_pps_value_type is of VALUE_TYPE_xxx_UNIQ")
              # Check if there is similar entry 
              similar_mir = email_bill_entry.meant_it_rels.where("src_endpoint_id = #{self.src_endpoint.id}")
              if similar_mir.size > 1
                # This should not be happening!!!
                logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, there are more than 1 mirs with same src_endpoint:#{self.src_endpoint}, i.e., similar_mir.inspect:#{similar_mir.inspect}")
                raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, there are more than 1 mirs with same src_endpoint:#{self.src_endpoint}, i.e., similar_mir.inspect:#{similar_mir.inspect}"
              end # end if similar_mir.size > 1
              if similar_mir.size > 0
                if OVERRIDE_MIR
                  logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, COND: !email_bill_entry.nil?, dst_endpoint_pii_pps_value_type is of VALUE_TYPE_xxx_UNIQ, similar_mir.size > 0 and OVERRIDE_MIR")
                  # Remove it and add this instead
                  similar_mir[0].email_bill_entry_id = nil
                  unless similar_mir[0].save
                    logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, could not remove similar_mir[0].inspect:#{similar_mir[0].inspect} from email_bill_entry.inspect:#{email_bill_entry.inspect}, similar_mir[0].errors.inspect:#{similar_mir[0].errors.inspect}")
                    raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, could not remove similar_mir[0].inspect:#{similar_mir[0].inspect} from email_bill_entry.inspect:#{email_bill_entry.inspect}, similar_mir[0].errors.inspect:#{similar_mir[0].errors.inspect}"
                  end # end unless similar_mir[0].save
                  email_bill_entry.meant_it_rels << self
                  # Update email_bill_entry's qty
                  if dst_endpoint_pii_pps_value_type == ValueTypeValidator::VALUE_TYPE_VALUE_UNIQ
                    logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, COND: !email_bill_entry.nil?, dst_endpoint_pii_pps_value_type is of VALUE_TYPE_xxx_UNIQ, similar_mir.size > 0 and OVERRIDE_MIR, VALUE_TYPE_VALUE_UNIQ, replace mir, update qty")
                    new_value = ControllerHelper.sum_currency_in_str(orig_msg, 0)
                    similar_mir_orig_msg = ControllerHelper.get_text_from_inbound_email(similar_mir[0].inbound_email)
                    old_value = ControllerHelper.sum_currency_in_str(similar_mir_orig_msg, 0)
                    subtractee_str = "#{email_bill_entry.currency}#{email_bill_entry.qty} #{new_value}"
                    subtractor_str = "#{old_value}"
                    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, subtractee_str:#{subtractee_str}, subtractor_str:#{subtractor_str}")
                    email_bill_entry_qty_str = ControllerHelper.subtract_currency_in_str(subtractee_str, subtractor_str, 0)
                    email_bill_entry.currency, email_bill_entry.qty = ControllerHelper.get_currency_code_and_val(email_bill_entry_qty_str)
                  else
                     logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, COND: !email_bill_entry.nil?, dst_endpoint_pii_pps_value_type is of VALUE_TYPE_xxx_UNIQ, similar_mir.size > 0 and OVERRIDE_MIR, VALUE_TYPE_COUNT_UNIQ, replace mir, but count doesn't change so no qty update")
                     # We replace the mir but the count remains same
                     # i.e., we remove old one and add new one
                  end # end if dst_endpoint_pii_pps_value_type == ValueTypeValidator::VALUE_TYPE_VALUE_UNIQ
                else
                  # Use the old mir so do nothing
                  logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, COND: !email_bill_entry.nil?, dst_endpoint_pii_pps_value_type is of VALUE_TYPE_xxx_UNIQ, similar_mir.size > 0 and !OVERRIDE_MIR, use old mir")
                end # end if OVERRIDE_MIR
              else
                logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, COND: email_bill_entry.inspect:#{email_bill_entry.inspect}, dst_endpoint_pii_pps_value_type is of VALUE_TYPE_xxx_UNIQ, similar_mir.size == 0, add mir, update qty")
                # Add the item
                email_bill_entry.meant_it_rels << self
                # Update email_bill_entry's qty
#20111114                message_val_str = add_value_by_value_type(orig_msg, dst_endpoint_pii_pps_value_type)
#20111114                sum_str = "#{message_val_str} #{email_bill_entry.currency}#{email_bill_entry.qty}"
#20111114                logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, sum_str:#{sum_str}")
#20111114                begin
#20111114                  email_bill_entry_qty_str = ControllerHelper.sum_currency_in_str(sum_str, 0)
#20111114                rescue Exception => e
#20111114                  logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, sum_str:#{sum_str} cannot be summed setting output to 0")
#20111114                  email_bill_entry_qty_str = "0"
#20111114                end # end rescue Exception
                email_bill_entry_qty_str = add_value_by_value_type(orig_msg, dst_endpoint_pii_pps_value_type, email_bill_entry.qty, email_bill_entry.currency)
                email_bill_entry.currency, email_bill_entry.qty = ControllerHelper.get_currency_code_and_val(email_bill_entry_qty_str)
              end # end if similar_mir.size > 0
            else
              logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, COND: email_bill_entry.inspect:#{email_bill_entry.inspect}, dst_endpoint_pii_pps_value_type is of !VALUE_TYPE_xxx_UNIQ, add mir, update qty")
              # Allow each sender multiple entries so just
              # add the item
              email_bill_entry.meant_it_rels << self
              # Update email_bill_entry's qty
#20111114              message_val_str = add_value_by_value_type(orig_msg, dst_endpoint_pii_pps_value_type)
#20111114              sum_str = "#{message_val_str} #{email_bill_entry.currency}#{email_bill_entry.qty}"
#20111114              begin
#20111114                email_bill_entry_qty_str = ControllerHelper.sum_currency_in_str(sum_str, 0)
#20111114              rescue Exception => e
#20111114                logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, sum_str:#{sum_str} cannot be summed setting output to 0")
#20111114                email_bill_entry_qty_str = "0"
#20111114              end # end rescue Exception
              email_bill_entry_qty_str = add_value_by_value_type(orig_msg, dst_endpoint_pii_pps_value_type, email_bill_entry.qty, email_bill_entry.currency)
              email_bill_entry.currency, email_bill_entry.qty = ControllerHelper.get_currency_code_and_val(email_bill_entry_qty_str)
            end # end if email_bill_entry.nil?
            unless email_bill_entry.save
              logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, after modifying email_bill_entry could not save email_bill_entry.inspect.inspect:#{email_bill_entry.inspect}, email_bill_entry.errors.inspect:#{email_bill_entry.errors.inspect}")
              raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, after modifying email_bill_entry could not save email_bill_entry.inspect.inspect:#{email_bill_entry.inspect}, email_bill_entry.errors.inspect:#{email_bill_entry.errors.inspect}"
            end # end unless email_bill_entry.save
#20111113            dst_endpoint_pii_pps_threshold_currency, dst_endpoint_pii_pps_threshold_val = ControllerHelper.get_currency_code_and_val(dst_endpoint_pii.pii_property_set.threshold)
            dst_endpoint_pii_pps_threshold_currency = dst_endpoint_pii.pii_property_set.currency
            dst_endpoint_pii_pps_threshold_val = dst_endpoint_pii.pii_property_set.threshold
            logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, email_bill_entry.qty:#{email_bill_entry.qty}, dst_endpoint_pii_pps_threshold_val:#{dst_endpoint_pii_pps_threshold_val}, dst_endpoint_pii_pps_threshold_currency:#{dst_endpoint_pii_pps_threshold_currency}")
            if email_bill_entry.currency != dst_endpoint_pii_pps_threshold_currency
              logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, email_bill_entry.currency:#{email_bill_entry.currency}, dst_endpoint_pii_pps_threshold_currency:#{dst_endpoint_pii_pps_threshold_currency} does not match!")
              raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, email_bill_entry.currency:#{email_bill_entry.currency}, dst_endpoint_pii_pps_threshold_currency:#{dst_endpoint_pii_pps_threshold_currency} does not match!"
            end # end if email_bill_entry.currency != dst_endpoint_pii_pps_threshold_currency
            if email_bill_entry.qty.to_f >= dst_endpoint_pii_pps_threshold_val.to_f
#20111109              # Recount all entries since, some entries may have been deleted,
#20111109              # etc.
#20111109              uniq = dst_endpoint_pii_pps_value_type == Constants::VALUE_TYPE_VALUE_UNIQ or dst_endpoint_pii_pps_value_type == Constants::VALUE_TYPE_COUNT_UNIQ
#20111109              mirs, start_bill_date, end_bill_date = ControllerHelper.get_latest_likers_by_pii_value(dst_endpoint_pii.pii_value, StatusTypeValidator::STATUS_ACTIVE, uniq, logtag)
              # Remove all mirs from email_bill_entry
              # NOTE: This seem very risky so we don't do it but
              # instead we rely on the fact that we use status
              # to exclude those that has been DELETED etc.
              # so we only add entries that are missing but never delete
#20111109ABC              email_bill_entry.meant_it_rels { |mir_elem|
#20111109ABC                mir_elem.email_bill_entry_id = nil
#20111109ABC                unless mir_elem.save
#20111109ABC                  logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, after disassociating with email_bill_entry, could not save mirs mir_elem.inspect:#{mir_elem.inspect}")
#20111109ABC                  raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, after disassociating with email_bill_entry, could not save mirs mir_elem.inspect:#{mir_elem.inspect}"
#20111109ABC                end # end unless mir_elem.save
#20111109ABC              } # end email_bill_entry.meant_it_rels ...
#20111109              # Get the actual mirs
#20111109              pii_dst_endpoints = dst_endpoint_pii.endPoints.collect { |ep_elem| ep_elem.id }
#20111109              mirs.each { |mir_elem|
#20111109                mir_where_1 = MeantItRel.where(:src_endpoint_id => mir_elem.src_endpoint_id).where(:dst_endpoint_id => pii_dst_endpoints).where(:message_type => MeantItMessageTypeValidator::MEANT_IT_MESSAGE_LIKE)
#20111109                option_str_all = ControllerHelper.get_date_option_str(start_bill_date, end_bill_date, true)
#20111109                if !option_str_all.nil?
#20111109                  full_mirs = mir_where_1.where(option_str_all)
#20111109                else
#20111109                  full_mirs = mir_where_1
#20111109                end # end if !option_str_all.nil?
#20111109                if OVERRIDE_MIR
#20111109                  # Get the latest
#20111109                  full_mir = full_mirs[full_mirs.size-1]
#20111109                else
#20111109                  full_mir = full_mirs[0]
#20111109                end # end if OVERRIDE_MIR
#20111109                # if full_mir is not in the current bill add it
#20111109                if full_mir.email_bill_entry_id != email_bill_entry.id
#20111109                  email_bill_entry << full_mir
#20111109                end # end if full_mir.email_bill_entry_id != email_bill_entry.id
#20111109              } # end mirs.each ...
#20111109              unless email_bill_entry.save
#20111109                logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, after adjusting email_bill_entry with latest entries, could not save email_bill_entry.inspect.inspect:#{email_bill_entry.inspect}, email_bill_entry.errors.inspect:#{email_bill_entry.errors.inspect}")
#20111109                raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, after with latest entries, could not save email_bill_entry.inspect.inspect:#{email_bill_entry.inspect}, email_bill_entry.errors.inspect:#{email_bill_entry.errors.inspect}"
#20111109              end # end unless email_bill_entry.save
#20111109            end # end if email_bill_entry.qty >= dst_endpoint_pii_pps_threshold
              email_bill_entry.ready_date = Time.now
              # If we are accumulating value then there is no unit price
              email_bill_entry.price_final = ControllerHelper.get_price_from_formula(dst_endpoint_pii.pii_property_set.formula) if dst_endpoint_pii_pps_value_type == ValueTypeValidator::VALUE_TYPE_COUNT_UNIQ or dst_endpoint_pii_pps_value_type == ValueTypeValidator::VALUE_TYPE_COUNT
              email_bill_entry.threshold_final = dst_endpoint_pii.pii_property_set.threshold
              logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, pii_value:#{dst_endpoint_pii.pii_value} met set threshold of #{dst_endpoint_pii.pii_property_set.threshold}")
              pps = dst_endpoint_pii.pii_property_set
              # If onetime, then set status to LIKER_STATUS_BILLED
              if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
                pps.status = StatusTypeValidator::STATUS_INACTIVE
                unless pps.save
                  logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, failed to change pii_value:#{pii_value} pps status to #{StatusTypeValidator::STATUS_INACTIVE}")
                  raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, failed to change pii_value:#{pii_value} pps status to #{StatusTypeValidator::STATUS_ACTIVE}"
                end # end unless pps.save
              elsif pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_RECUR
                # Don't need to do anything
              else
                logger.error("#{File.basename(__FILE__)}:#{self.class}:check_pii_property_set_threshold_v2, pps.threshold_type:#{pps.threshold_type} not supported by billing system")
                raise Exception, "#{File.basename(__FILE__)}:#{self.class}:check_pii_property_set_threshold_v2, pps.threshold_type:#{pps.threshold_type} not supported by billing system"
              end # end if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
              # Reget the pii because it will only have partial info
              pii_0 = Pii.find_by_pii_value(dst_endpoint_pii.pii_value)
              unless dst_endpoint_pii.pii_property_set.save
                logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, setting dst_endpoint_pii.pii_property_set.ready to true failed, dst_endpoint_pii.pii_property_set.errors.inspect:#{dst_endpoint_pii.pii_property_set.errors.inspect}")
                raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:check_pii_property_set_threshold_v2, setting dst_endpoint_pii.pii_property_set.ready to true failed, dst_endpoint_pii.pii_property_set.errors.inspect:#{dst_endpoint_pii.pii_property_set.errors.inspect}"
              end # end unless dst_endpoint_pii.pii_property_set.save
              # Send email
              UserMailer.threshold_mail(pii_0).deliver
            end # end if email_bill_entry.qty.to_f >= dst_endpoint_pii_pps_threshold_val.to_f
          end # end if !dst_endpoint_pii.pii_property_set.nil? and  ...
        end # end if ControllerHelper.sellable_pii(dst_endpoint_pii)
      end # end if self.message_type ==  ... MEANT_IT_MESSAGE_LIKE
    end # end def check_pii_property_set_threshold_v2
end
