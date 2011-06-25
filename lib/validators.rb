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
  MOOD_REASONER_DEFAULT = "mood_processor"
  MOOD_REASONER_ENUM = [ MOOD_REASONER_DEFAULT ]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{MOOD_REASONER_ENUM.join('\', \'').strip}'" if value.nil? or MOOD_REASONER_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class MoodValidator
