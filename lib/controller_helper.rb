module ControllerHelper
  LOGTAG_MAX = 2**32

  def self.gen_logtag
    rand(LOGTAG_MAX)
  end # end def gen_logtag

  def self.create_entity_by_name_email(name, email, logtag=nil)
    return_obj = nil
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
      return_obj = new_person
      raise Exception if !new_person.errors.empty?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:create_entity_by_name_email:#{logtag}, new_person:#{new_person.inspect}")
      # Create entity
      new_entity = Entity.create(:property_document_id => new_person.id)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:create_entity_by_name_email:#{logtag}, new_entity:#{new_entity.inspect}")
      return_obj = new_entity
      raise Exception if !new_entity.errors.empty?
      new_entity.entityEndPointRels.create(:verification_type => "email")
    rescue Exception => e
    end
    # Note: return_obj.errors tells the caller what went wrong
    return return_obj
  end # end def self.create_entity_by_name_email
end # end module ControllerHelper

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
    field_mapper[:attachment_count] = :attachements
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
