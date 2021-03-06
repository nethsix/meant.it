class ValueTypeValidator < ActiveModel::EachValidator
  VALUE_TYPE_COUNT = "count"
  VALUE_TYPE_COUNT_UNIQ = "count_uniq"
  VALUE_TYPE_VALUE = "value"
  VALUE_TYPE_VALUE_UNIQ = "value_uniq"
  VALUE_TYPE_ENUM = [ VALUE_TYPE_COUNT, VALUE_TYPE_COUNT_UNIQ, VALUE_TYPE_VALUE, VALUE_TYPE_VALUE_UNIQ ]

  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{VALUE_TYPE_ENUM.join('\', \'').strip}'" if value.nil? or VALUE_TYPE_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class ValueTypeValidator < ActiveModel::EachValidator

class LikerStatusTypeValidator < ActiveModel::EachValidator
  LIKER_STATUS_ACTIVE = "active"
  LIKER_STATUS_INACTIVE = "inactive"
  LIKER_STATUS_READY = "ready" # Threshold reached
  LIKER_STATUS_BILLED = "billed"
  LIKER_STATUS_ENUM = [ LIKER_STATUS_ACTIVE, LIKER_STATUS_INACTIVE, LIKER_STATUS_READY, LIKER_STATUS_BILLED ]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{LIKER_STATUS_ENUM.join('\', \'').strip}'" if value.nil? or LIKER_STATUS_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class LikerStatusTypeValidator

class PaymentStatusTypeValidator < ActiveModel::EachValidator
  # Initial state
  PAYMENT_STATUS_ACTIVE = "active"
  # User click cancel while going through payment procedure
  PAYMENT_STATUS_CANCELLED = "cancelled"
  # We (admin) can set this
  PAYMENT_STATUS_INACTIVE = "inactive"
  PAYMENT_STATUS_DONE = "done"
  PAYMENT_STATUS_ENUM = [ PAYMENT_STATUS_ACTIVE, PAYMENT_STATUS_CANCELLED, PAYMENT_STATUS_INACTIVE, PAYMENT_STATUS_DONE ]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{PAYMENT_STATUS_ENUM.join('\', \'').strip}'" if value.nil? or PAYMENT_STATUS_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class PaymentStatusTypeValidator

class StatusTypeValidator < ActiveModel::EachValidator
  STATUS_ACTIVE = "active"
  STATUS_INACTIVE = "inactive"
  STATUS_ENUM = [ STATUS_ACTIVE, STATUS_INACTIVE ]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{STATUS_ENUM.join('\', \'').strip}'" if value.nil? or STATUS_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class StatusTypeValidator

class PiiHideTypeValidator < ActiveModel::EachValidator
  PII_HIDE_TRUE = "true"
  PII_HIDE_FALSE = "false"
  PII_HIDE_ENUM = [ PII_HIDE_TRUE, PII_HIDE_FALSE ]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{PII_HIDE_ENUM.join('\', \'').strip}'" if value.nil? or PII_HIDE_ENUM.index(value.downcase).nil?
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
      if entityData.nil? or !entityData.errors.empty?
      record.errors[attribute] << "does not point to a valid doc in couchdb: #{e.inspect}, nor point to a valid record in EntityData table"
      end # end if !entityData.errors.empty?
    end # end @db.get ...
  end # end def validate_each
end # end class DocIdForeignKeylidator

class MeantItMessageTypeValidator < ActiveModel::EachValidator
  MEANT_IT_MESSAGE_THANK = "thank"
  MEANT_IT_MESSAGE_LIKE = "like"
  MEANT_IT_MESSAGE_CHEER = "cheer"
  MEANT_IT_MESSAGE_SYMPATHY = "sympathy" # INACTIVE
  MEANT_IT_MESSAGE_RESENT = "resent" # INACTIVE
  MEANT_IT_MESSAGE_OTHER = "other"
  MEANT_IT_MESSAGE_ORGANIZE = "organize" # INACTIVE
  MEANT_IT_MESSAGE_SORRY = "sorry"
  MEANT_IT_MESSAGE_LOST = "lost" # INACTIVE
  MEANT_IT_MESSAGE_FOUND = "found"
  MEANT_IT_MESSAGE_PROTEST = "protest"
  MEANT_IT_MESSAGE_ADVISE = "advise"
  MEANT_IT_MESSAGE_REGRET = "regret" # INACTIVE
  
  MEANT_IT_MESSAGE_TYPE_ENUM = [ MEANT_IT_MESSAGE_THANK, MEANT_IT_MESSAGE_LIKE, MEANT_IT_MESSAGE_CHEER, MEANT_IT_MESSAGE_OTHER, MEANT_IT_MESSAGE_SORRY, MEANT_IT_MESSAGE_FOUND, MEANT_IT_MESSAGE_PROTEST, MEANT_IT_MESSAGE_ADVISE ]
  def validate_each(record, attribute, value)
    msg_type_downcase = value.downcase if !value.nil?
    normalized_msg_type_downcase = MessageTypeMapper.get_message_type(msg_type_downcase)
    record.errors[attribute] << "message_type:#{normalized_msg_type_downcase} not allowed, permits only '#{MessageTypeMapper.get_all_message_types.join('\', \'').strip}, #{MEANT_IT_MESSAGE_TYPE_ENUM.join('\', \'').strip}'" if normalized_msg_type_downcase.nil?
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
  PII_TYPE_GLOBAL = "global"
  PII_TYPE_OTHER = "other"
  PII_TYPE_ENUM = [ PII_TYPE_PASSPORT, PII_TYPE_EMAIL, PII_TYPE_ID_CARD, PII_TYPE_SSN, PII_TYPE_GLOBAL, PII_TYPE_OTHER ]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{PII_TYPE_ENUM.join('\', \'').strip}'" if value.nil? or PII_TYPE_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class PiiTypeValidator

class VerificationTypeValidator < ActiveModel::EachValidator
  VERIFICATION_TYPE_PHONE = "phone"
  VERIFICATION_TYPE_PHYSICAL = "physical"
  VERIFICATION_TYPE_EMAIL = "email"
  VERIFICATION_TYPE_AUTO_ENTITY_DOMAIN = "auto_entity_domain"
  VERIFICATION_TYPE_ENUM = [ VERIFICATION_TYPE_PHONE, VERIFICATION_TYPE_PHYSICAL, VERIFICATION_TYPE_EMAIL, VERIFICATION_TYPE_AUTO_ENTITY_DOMAIN ]
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

class PiiPropertySetThresholdTypeValidator < ActiveModel::EachValidator
  THRESHOLD_TYPE_ONETIME = "onetime"
  THRESHOLD_TYPE_RECUR = "recur"
  THRESHOLD_TYPE_ENUM = [THRESHOLD_TYPE_ONETIME, THRESHOLD_TYPE_RECUR]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{THRESHOLD_TYPE_ENUM.join('\', \'').strip}'" if value.nil? or THRESHOLD_TYPE_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class PiiPropertySetThresholdTypeValidator < ActiveModel::EachValidator

class SimpleNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "only alphabets, numbers, and underscore" if value.nil? or value.empty? or !value.match(/[^0-9a-zA-Z_\-+.@]/).nil?
  end # end def validate_each(record, attribute, value)
end # end class SimpleNameValidator

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
  @@msg_type_map_hash["others"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_OTHER
  @@msg_type_map_hash["organizes"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_ORGANIZE
  @@msg_type_map_hash["regrets"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_REGRET
  @@msg_type_map_hash["resents"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_RESENT
  @@msg_type_map_hash["likes"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_LIKE
  @@msg_type_map_hash["cheers"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_CHEER
  @@msg_type_map_hash["protests"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_PROTEST
  @@msg_type_map_hash["advises"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_ADVISE
  @@msg_type_map_hash["advice"] = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_ADVISE

  def self.get_all_message_types
    @@msg_type_map_hash.keys
  end # end def self.get_all_message_types

  def self.get_message_type(message_type)
    msg_type_downcase = message_type.downcase if !message_type.nil?
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
