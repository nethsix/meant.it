require 'validators'

module ControllerHelper
  LOGTAG_MAX = 2**32

  def self.gen_logtag
    rand(LOGTAG_MAX)
  end # end def gen_logtag

  def self.find_or_create_person_by_email(name, email, logtag=nil)
    new_person = nil
    begin
      # Create propertyId
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:create_entity_by_name_email:#{logtag}, name:#{name}, email:#{email}")
      new_person = Person.find_by_email(email)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:create_entity_by_name_email:#{logtag}, find_by_email new_person:#{new_person.inspect}")
      if new_person.nil?
        new_person = Person.create(:name => name, :email => email)
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:create_entity_by_name_email:#{logtag}, create new_person:#{new_person.inspect}")
      end # end if new_person.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:create_entity_by_name_email:#{logtag}, new_person.errors:#{new_person.errors.inspect}")
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:create_entity_by_name_email:#{logtag}, new_person:#{new_person.inspect}")
   rescue Exception => e
      # Usually because couchdb is not there
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:create_entity_by_name_email:#{logtag}, person find/create triggered exception, e.inspect:#{e.inspect}")
      # Use sql instead of couchdb
      new_person = EntityDatum.find_or_create_by_email(:email => email)
   end # end find/create person
   new_person
  end # end def self.find_or_create_person_by_email
end # end module ControllerHelper

# This is to help meant_it_rels message_type DRY
# Note this is not intended to keep message_type in MEANT_IT_MESSAGE_OTHER
# DRY.  For those we sort them based on class mood.
class MessageTypeMapper
  @@msg_type_map_hash ||= {}
  @@msg_type_map_hash["thanks"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_THANK
  @@msg_type_map_hash["thx"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_THANK
  @@msg_type_map_hash["thks"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_THANK
  @@msg_type_map_hash["sympathize"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_SYMPATHY
  @@msg_type_map_hash["sympathizes"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_SYMPATHY
  @@msg_type_map_hash["consoles"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_SYMPATHY
  @@msg_type_map_hash["console"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_SYMPATHY
  @@msg_type_map_hash["other"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_SYMPATHY
  @@msg_type_map_hash["others"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_SYMPATHY

  def self.get_all_message_types
    @@msg_type_map_hash.keys
  end # end def self.get_all_message_types

  def self.get_message_type(message_type)
    msg_type_downcase = message_type.downcase
    final_msg_type = nil
    # Don't need to map if it's in the 
    if MeantItMessageTypeValidator::MEANT_IT_MESSAGE_TYPE_ENUM.index(msg_type_downcase).nil?
      final_msg_type = @@msg_type_map_hash[msg_type_downcase]
    else
      final_msg_type = msg_type_downcase
    end # end if MEANT_IT_MESSAGE_TYPE_ENUM.index(msg_type_downcase).nil?
    final_msg_type
  end # end def self.get_message_type(message_type)
end # end class MessageTypeMapper

class InboundEmailFieldMapperFactory
  SENDGRID = :sendgrid
  def self.set_default_mapping(field_mapper)
    field_name_arr = InboundEmail.new.attributes.keys
    field_name_arr.each { |key|
      field_mapper[key.to_sym] = key.to_sym
    } # end field_name_arr
  end # end def self.set_default_mapping

  def self.set_sendgrid_mapping(field_mapper)
    field_mapper[:body_text] = :text
    field_mapper[:body_html] = :html
    field_mapper[:attachment_count] = :attachments
  end # end def self.set_sendgrid_mapping

  def self.get_inbound_email_field_mapper(name = nil)
    field_mapper = {}
    set_default_mapping(field_mapper)
    case(name)
      when SENDGRID
        set_sendgrid_mapping(field_mapper)
    end # end case
    field_mapper
  end # end def self.get_inbound_email_field_mapper
end # end class InboundEmailFieldMapperFactory
