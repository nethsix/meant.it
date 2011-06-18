class StatusTypeValidator < ActiveModel::EachValidator
  STATUS_ENUM = ["active", "inactive", "deleted"]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{STATUS_ENUM.join('\', \'').strip}'" if STATUS_ENUM.index(value.downcase).nil?
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
    @conn ||= CouchRest.new("#{COUCHDB_ADDR}:#{COUCHDB_PORT}")
    @db ||= @conn.database(COUCHDB_ENTITY_PROPERTIES)
    begin
      couchdb_doc = @db.get(value)
    rescue Exception => e
      record.errors[attribute] << "does not point to a valid doc in couchdb: #{e.inspect}"
    end # end @db.get ...
  end # end def validate_each
end # end class DocIdForeignKeylidator

class MeantItMessageTypeValidator < ActiveModel::EachValidator
  MEANT_IT_MESSAGE_TYPE_ENUM = ["thank", "sympathy", "resent"]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{MEANT_IT_MESSAGE_TYPE_ENUM.join('\', \'').strip}'" if MEANT_IT_MESSAGE_TYPE_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class MeantItMessageTypeValidator

class ObjRelTypeValidator < ActiveModel::EachValidator
  OBJ_REL_TYPE_ENUM = ["alias", "type_of", "in"]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{OBJ_REL_TYPE_ENUM.join('\', \'').strip}'" if OBJ_REL_TYPE_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class ObjRelTypeValidator

class PiiTypeValidator < ActiveModel::EachValidator
  PII_TYPE_ENUM = ["passport", "email", "id_card", "ssn"]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{PII_TYPE_ENUM.join('\', \'').strip}'" if PII_TYPE_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class PiiTypeValidator

class VerificationTypeValidator < ActiveModel::EachValidator
  VERIFICATION_TYPE_ENUM = ["phone", "physical", "email"]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{VERIFICATION_TYPE_ENUM.join('\', \'').strip}'" if VERIFICATION_TYPE_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class VerificationTypeValidator

class ObjRelObjTypeValidator < ActiveModel::EachValidator
  OBJ_REL_OBJ_TYPE_ENUM = ["tag", "end_point"]
  def validate_each(record, attribute, value)
    record.errors[attribute] << "permits only '#{OBJ_REL_OBJ_TYPE_ENUM.join('\', \'').strip}'" if OBJ_REL_OBJ_TYPE_ENUM.index(value.downcase).nil?
  end # end def validate_each
end # end class VerificationTypeValidator

class BodyOrSubjectNotNullValidator < ActiveModel::Validator
  def validate(record)
    if (record.subject.nil? or record.subject.empty?) and (record.body_text.nil? or record.body_text.empty?)
      record.errors[:base] << "Either body text or subject must contain something"
    end # end if (record.subject.nil? ... )
  end # end def validate(record)
end # end class BodyOrSubjectNotNullValidator
