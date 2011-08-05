require 'controller_helper'
class UserMailer < ActionMailer::Base
  default :from => "mailer@meant.it"

  def threshold_mail(pii)
    logtag = ControllerHelper.gen_logtag
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
    mail(:to => email, :subject => "Threshold of #{threshold} for pii:#{pii_value} (#{short_desc}) reached!")
  end # end def threshold_mail
end
