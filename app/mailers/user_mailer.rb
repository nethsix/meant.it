require 'controller_helper'
require 'errors'
class UserMailer < ActionMailer::Base
  default :from => "mailer@meant.it"

  def threshold_mail(pii, logtag = nil)
    @pii = pii
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:threshold_mail:#{logtag}, @pii.inspect:#{@pii.inspect}")
    pii_value = @pii.pii_value
    short_desc = nil
    threshold = nil
    threshold_currency = nil
    if !@pii.pii_property_set.nil?
      short_desc = @pii.pii_property_set.short_desc
      threshold = @pii.pii_property_set.threshold
      threshold_currency = @pii.pii_property_set.currency
    end # end if !@pii.pii_property_set.nil?
    # Get email from pii_property_set
    email = nil
    if !@pii.pii_property_set.nil?
      email = @pii.pii_property_set.notify
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:threshold_mail:#{logtag}, @pii.pii_property_set.notify:#{@pii.pii_property_set.notify}")
    end # end if !@pii.pii_property_set.nil?
    # Check if it's email CODE
    # Get it from entity
    pii_sender_endPoint = ControllerHelper.get_sender_endPoint_from_endPoints(pii.endPoints)
    if !pii_sender_endPoint.entities.nil? and !pii_sender_endPoint.entities.empty?
      pii_sender_endPoint.entities.each { |pii_entity_elem|
        @entity = pii_entity_elem
        logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:threshold_mail:#{logtag}, @entity.inspect:#{@entity.inspect}")
        if !pii_entity_elem.property_document_id.nil?
          @person = ControllerHelper.find_person_by_id(pii_entity_elem.property_document_id)
          logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:threshold_mail:#{logtag}, @person.inspect:#{@person.inspect}")
          if email.nil? or email.empty?
            if !@person.nil? and !@person.email.nil? and !@person.email.empty?
              email = @person.email
              break
            end # end if !@person.nil? and !@person.email.nil? and  ...
          else
            break
          end # end if email.nil? or email.empty?
        end # end if !pii_entity_elem.property_document_id.nil?
      } # end pii_sender_endPoint.entities.each { |pii_entity_elem|
    end # end if !pii_sender_endPoint.entities.nil? and !pii_sender_endPoint.entities.empty?
    if email.nil? or email.empty?
      logger.warn("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:threshold_mail:#{logtag}, pii_value:#{pii_value} has no email") 
      # Don't send notification email
    else
      mail(:to => email, :subject => "Threshold of #{ControllerHelper.threshold_display_str_from_attr(threshold_currency, threshold)} for pii:#{pii_value} (#{short_desc}) reached!")
    end # end if email.nil? or email.empty?
  end # end def threshold_mail

#20111106  def contract_mail(likee_pii_value, email, src_endpoint, logtag = nil)
  def contract_mail(likee_pii_value, mir_elem, logtag = nil)
    src_endpoint = mir_elem.src_endpoint
    email = src_endpoint.pii.pii_value
    @pii = src_endpoint.pii
#20111106    @contract_no = ControllerHelper.gen_contract_no(likee_pii_value, src_endpoint)
    @contract_no = ControllerHelper.gen_contract_no(likee_pii_value, mir_elem)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:contract_mail:#{logtag}, @pii.inspect:#{@pii.inspect}")
    short_desc = nil
    threshold = nil
    @likee_pii = Pii.find_by_pii_value(likee_pii_value)
    if !@likee_pii.pii_property_set.nil?
      short_desc = @likee_pii.pii_property_set.short_desc
      threshold = @likee_pii.pii_property_set.threshold
    end # end if !@likee_pii.pii_property_set.nil?
    begin
      # Moved from payments_controller.rb
      # NOTE: We create object payments here instead of at sessions_controller
      # since we create the contract no. (invoice no) here
      # Get all values required for payment
      value_type = mir_elem.email_bill_entry.pii_property_set.value_type
      threshold_currency = mir_elem.email_bill_entry.pii_property_set.currency
      item_long_desc = mir_elem.email_bill_entry.pii_property_set.long_desc
      input_str = mir_elem.inbound_email.subject
      input_str ||= mir_elem.inbound_email.body_text
      formula = mir_elem.email_bill_entry.pii_property_set.formula
      amount_curr_code = nil
      amount_curr_val = nil
      item_qty = nil
      if value_type == ValueTypeValidator::VALUE_TYPE_VALUE or value_type == ValueTypeValidator::VALUE_TYPE_VALUE_UNIQ
        item_qty = 1
        amount_str = ControllerHelper.sum_currency_in_str(input_str)
        amount_curr_code, amount_curr_val = ControllerHelper.get_currency_code_and_val(amount_str)
        # Double-check that currency type matches
        if amount_curr_code != threshold_currency
          logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}: amount_curr_code:#{amount_curr_code} does not match threshold_currency:#{threshold_currency}")
          raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}: amount_curr_code:#{amount_curr_code} does not match threshold_currency:#{threshold_currency}"
        end # end if amount_curr_code != threshold_currency
        @value_type_input_str = input_str
      else
        # CODE!!!!!!
        # For now each mir when value_type is VALUE_TYPE_COUNT_xxx is
        # counted as 1. In future, we may allow more than 1 count, i.e.,
        # the message may have "qty=xx"
        item_qty = 1
        amount_curr_code = ControllerHelper.get_currency_from_formula(mir.email_bill_entry.pii_property_set.formula)
        amount_curr_val = ControllerHelper.get_price_from_formula(mir.email_bill_entry.pii_property_set.formula)
      end # end if value_type == ValueTypeValidator::VALUE_TYPE_VALUE or value_type == ValueTypeValidator::VALUE_TYPE_VALUE_UNIQ
      # Create payment object
      # CODE!!!! In future create a function to calculate this
      total = amount_curr_val
      payment = Payment.create(:item_no => likee_pii_value, :quantity => item_qty,  :item_name => short_desc, :amount => amount_curr_val, :currency_code => amount_curr_code, :total => total, :invoice_no => @contract_no, :meant_it_rel_id => mir_elem.id)
      if payment.errors.any?
        logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:payment creation error, payment.errors.inspect:#{payment.errors.inspect}")
        raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:payment creation error, payment.errors.inspect:#{payment.errors.inspect}"
      end # end if payment.errors.any?
      # Send email
      mail(:to => email, :subject => "pii:#{likee_pii_value} (#{short_desc}) is now ready for purchase!")
    rescue Exception => e
      logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:contract_mail delivery error, e.inspect:#{e.inspect}")
      logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:contract_mail delivery error trace, e.backtrace:#{e.backtrace.join("\n")}")
      pay_error = PaymentException.new(@contract_no)
      raise pay_error, "Payment error for @contract_no:#{@contract_no}, e.inspect:#{e.inspect}"
    end # end contral_mail delivery error
  end # end def contract_mail
end
