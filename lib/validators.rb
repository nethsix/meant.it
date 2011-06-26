class StatusTypeValidator < ActiveModel::EachValidator
  STATUS_ACTIVE = "active"
  STATUS_INACTIVE = "inactive"
  STATUS_ENUM = [ STATUS_ACTIVE, STATUS_INACTIVE ]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{STATUS_ENUM.join('\', \'').strip}'" if value.nil? or STATUS_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class StatusTypeValidator

#20110612 class DocIdForeignKeyValidator < ActiveModel::EachValidator
class PropertyDocumentIdForeignKeyValidator < ActiveModel::EachValidator
  COUCHDB_ADDR = '127.0.0.1'
  COUCHDB_PORT = 5984
  COUCHDB_ENTITY_PROPERTIES = 'meant_it'
  def validate_each(record, attribute, value)
    #20110612 Ensure that doc_id points to a valid doc in couchdb
    # Ensure that propertyDocument_id points to a valid doc in couchdb
    begin
      @conn ||= CouchRest.new("#{COUCHDB_ADDR}:#{COUCHDB_PORT}")
      @db ||= @conn.database(COUCHDB_ENTITY_PROPERTIES)
      couchdb_doc = @db.get(value)
    rescue Exception => e
#      record.errors[attribute] << "does not point to a valid doc in couchdb: #{e.inspect}"
      # Check active record
      entityData = EntityDatum.find_by_id(value)
      if !entityData.errors.empty?
      record.errors[attribute] << "does not point to a valid doc in couchdb: #{e.inspect}, nor point to a valid record in EntityData table"
      end # end if !entityData.errors.empty?
    end # end @db.get ...
  end # end def validate_each
end # end class DocIdForeignKeylidator

class MeantItMessageTypeValidator < ActiveModel::EachValidator
  MEANT_IT_MESSAGE_THANK = "thank"
  MEANT_IT_MESSAGE_SYMPATHY = "sympathy"
  MEANT_IT_MESSAGE_RESENT = "resent"
  MEANT_IT_MESSAGE_OTHER= "other"
  MEANT_IT_MESSAGE_TYPE_ENUM = [ MEANT_IT_MESSAGE_THANK, MEANT_IT_MESSAGE_SYMPATHY, MEANT_IT_MESSAGE_RESENT ]
  def validate_each(record, attribute, value)
    msg_type_downcase = value.downcase
    normalized_msg_type_downcase = MessageTypeMapper.get_message_type(msg_type_downcase)
    record.errors[attribute] << "permits only '#{MessageTypeMapper.get_all_message_types.join('\', \'').strip}'" if normalized_msg_type_downcase.nil?
  end # end def validate_each
end # end class MeantItMessageTypeValidator

class ObjRelTypeValidator < ActiveModel::EachValidator
  OBJ_REL_TYPE_ALIAS = "alias"
  OBJ_REL_TYPE_TYPE_OF = "type_of"
  OBJ_REL_TYPE_IN = "in"
  OBJ_REL_TYPE_ENUM = [ OBJ_REL_TYPE_ALIAS, OBJ_REL_TYPE_TYPE_OF, OBJ_REL_TYPE_IN ]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{OBJ_REL_TYPE_ENUM.join('\', \'').strip}'" if value.nil? or OBJ_REL_TYPE_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class ObjRelTypeValidator

class PiiTypeValidator < ActiveModel::EachValidator
  PII_TYPE_PASSPORT = "passport"
  PII_TYPE_EMAIL = "email"
  PII_TYPE_ID_CARD = "id_card"
  PII_TYPE_SSN = "ssn"
  PII_TYPE_ENUM = [ PII_TYPE_PASSPORT, PII_TYPE_EMAIL, PII_TYPE_ID_CARD, PII_TYPE_SSN ]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{PII_TYPE_ENUM.join('\', \'').strip}'" if value.nil? or PII_TYPE_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class PiiTypeValidator

class VerificationTypeValidator < ActiveModel::EachValidator
  VERIFICATION_TYPE_PHONE = "phone"
  VERIFICATION_TYPE_PHYSICAL = "physical"
  VERIFICATION_TYPE_EMAIL = "email"
  VERIFICATION_TYPE_ENUM = [ VERIFICATION_TYPE_PHONE, VERIFICATION_TYPE_PHYSICAL, VERIFICATION_TYPE_EMAIL ]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{VERIFICATION_TYPE_ENUM.join('\', \'').strip}'" if value.nil? or VERIFICATION_TYPE_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class VerificationTypeValidator

class ObjRelObjTypeValidator < ActiveModel::EachValidator
  OBJ_REL_OBJ_TYPE_TAG = "tag"
  OBJ_REL_OBJ_TYPE_END_POINT = "end_point"
  OBJ_REL_OBJ_TYPE_ENUM = [ OBJ_REL_OBJ_TYPE_TAG, OBJ_REL_OBJ_TYPE_END_POINT ]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{OBJ_REL_OBJ_TYPE_ENUM.join('\', \'').strip}'" if value.nil? or OBJ_REL_OBJ_TYPE_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class VerificationTypeValidator

class BodyOrSubjectNotNullValidator < ActiveModel::Validator
  def validate(record)
    if (record.subject.nil? or record.subject.empty?) and (record.body_text.nil? or record.body_text.empty?)
#      record.errors[:base] << "Either body text or subject must contain something"
      record.errors.add :body_text, "Either body text or subject must contain something"
      record.errors.add :subject, "Either body text or subject must contain something"
    end # end if (record.subject.nil? ... )
  end # end def validate(record)
end # end class BodyOrSubjectNotNullValidator

class MoodReasonerValidator < ActiveModel::EachValidator
  MOOD_REASONER_MOOD_PROCESSOR = "mood_processor"
  MOOD_REASONER_EMAIL_DERIVED = "email_derived"
  MOOD_REASONER_DEFAULT = MOOD_REASONER_EMAIL_DERIVED
  MOOD_REASONER_ENUM = [ MOOD_REASONER_MOOD_PROCESSOR, MOOD_REASONER_EMAIL_DERIVED ]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{MOOD_REASONER_ENUM.join('\', \'').strip}'" if value.nil? or MOOD_REASONER_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class MoodValidator

module ControllerHelper
  LOGTAG_MAX = 2**32

  MEANT_IT_INPUT_MESSAGE = :message
  MEANT_IT_INPUT_RECEIVER_PII = :receiver_pii
  MEANT_IT_INPUT_RECEIVER_NICK = :receiver_nick
  MEANT_IT_INPUT_TAGS = :tags

  def self.gen_logtag
    rand(LOGTAG_MAX)
  end # end def gen_logtag

  def self.parse_message_type_from_email_addr(email_addr, logtag = nil)
    message_type_str = nil
    email_addr_match_arr = nil
    email_addr_match_arr = email_addr.match /(.*)@.*/ if !email_addr.nil?
    if email_addr_match_arr.nil?
      message_type_str = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_THANK
    else
      message_type_str = MessageTypeMapper.get_message_type(email_addr_match_arr[1])
    end # end if email_addr_match_arr.nil?
    message_type_str
  end # end def self.parse_message_type_from_email

  def self.parse_meant_it_input(input_str, logtag = nil)
    input_str_dup = input_str.dup
    result_hash = {}
    # Determine nick, :xxx, :yyy, tags
    # Get those strings enclosed with quotes ' or "
    # NOTE: scan returns [['abc'], ['def']... thus we use collect
    # to convert to [abc, def, ...]
    # Nick is the first tag, no spaces are allowed for nick
    # Message is enclosed within ;
    message_str_arr = input_str_dup.scan(/;(.*);/).collect { |elem| elem[0] }
    message_str = message_str_arr[0]
    result_hash[MEANT_IT_INPUT_MESSAGE] = message_str
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, message_str:#{message_str}")
    message_str_arr.each { |msg_elem| input_str_dup.sub!(/;#{msg_elem};/, '') }
    receiver_pii_str_arr = input_str_dup.scan(/:(.*?)\s/).collect { |elem| elem[0] }
    receiver_pii_str = receiver_pii_str_arr[0]
    result_hash[MEANT_IT_INPUT_RECEIVER_PII] = receiver_pii_str
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, receiver_pii_str:#{receiver_pii_str}")
    receiver_pii_str_arr.each { |receiver_pii_elem| input_str_dup.sub!(/:#{receiver_pii_elem}/, '') }
    single_quote_tag_arr = input_str_dup.scan(/'(.*?)'/).collect { |elem| elem[0] }
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, single_quote_tag_arr.inspect:#{single_quote_tag_arr.inspect}")
    # Remove those quoted tags since we've processed them
    single_quote_tag_arr.each { |tag_elem| input_str_dup.sub!(/'#{tag_elem}'/, '') }
    double_quotes_tag_arr = input_str_dup.scan(/"(.*?)"/).collect { |elem| elem[0] }
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, double_quotes_tag_arr.inspect:#{double_quotes_tag_arr.inspect}")
    double_quotes_tag_arr.each { |tag_elem| input_str_dup.sub!(/"#{tag_elem}"/, '') }
    tag_str_arr = single_quote_tag_arr + double_quotes_tag_arr
    input_str_arr = input_str_dup.split
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, stripped input_str_arr.inspect:#{input_str_arr.inspect}")
    receiver_nick_str = input_str_arr.shift
    result_hash[MEANT_IT_INPUT_RECEIVER_NICK] = receiver_nick_str
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, receiver_nick_str:#{receiver_nick_str}")
    tag_str_arr += input_str_arr
    tag_str_arr.uniq!
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, tag_str_arr.inspect:#{tag_str_arr.inspect}")
    result_hash[MEANT_IT_INPUT_TAGS] = tag_str_arr
    result_hash
  end # end def.parse_meant_it_text

  def self.find_person_by_id(person_id, logtag=nil)
    person = nil
    begin
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_person_by_id:#{logtag}, person_id:#{person_id}")
      person = Person.find(person_id)
    rescue Exception => e
    end # end cannot find person from couchdb
    if person.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_person_by_id:#{logtag}, person find triggered exception, e.inspect:#{e.inspect}")
      # Use sql instead of couchdb
      person = EntityDatum.find_by_id(person_id)
    end # end if person.nil?
    person
  end # end def self.find_person_by_id

  def self.find_person_by_email(name, email, logtag=nil)
    person = nil
    begin
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_person_by_email:#{logtag}, name:#{name}, email:#{email}")
      person = Person.find_by_email(email)
    rescue Exception => e
    end # end cannot find person from couchdb
    if person.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_person_by_email:#{logtag}, person find triggered exception, e.inspect:#{e.inspect}")
      # Use sql instead of couchdb
      person = EntityDatum.find_by_email(:email => email)
    end # end if person.nil?
    person
  end # end def self.find_person_by_email(name, email, logtag=nil)

  def self.find_or_create_person_by_email(name, email, logtag=nil)
    new_person = nil
    begin
      # Create propertyId
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_or_create_person_by_email:#{logtag}, name:#{name}, email:#{email}")
      new_person = Person.find_by_email(email)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_or_create_person_by_email:#{logtag}, find_by_email new_person:#{new_person.inspect}")
      if new_person.nil?
        new_person = Person.create(:name => name, :email => email)
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_or_create_person_by_email:#{logtag}, create new_person:#{new_person.inspect}")
      end # end if new_person.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_or_create_person_by_email:#{logtag}, new_person.errors:#{new_person.errors.inspect}")
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_or_create_person_by_email:#{logtag}, new_person:#{new_person.inspect}")
   rescue Exception => e
      # Usually because couchdb is not there
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_or_create_person_by_email:#{logtag}, person find/create triggered exception, e.inspect:#{e.inspect}")
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
