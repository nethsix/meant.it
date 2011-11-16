require 'controller_helper'
class UserMailer < ActionMailer::Base
  default :from => "mailer@meant.it"

  def threshold_mail(pii, logtag = nil)
    @pii = pii
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:threshold_mail:#{logtag}, @pii.inspect:#{@pii.inspect}")
    pii_value = @pii.pii_value
    short_desc = nil
    threshold = nil
    if !@pii.pii_property_set.nil?
      short_desc = @pii.pii_property_set.short_desc
      threshold = @pii.pii_property_set.threshold
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
      mail(:to => email, :subject => "Threshold of #{threshold} for pii:#{pii_value} (#{short_desc}) reached!")
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
    mail(:to => email, :subject => "pii:#{likee_pii_value} (#{short_desc}) is now ready for purchase!")
  end # end def contract_mail
end
