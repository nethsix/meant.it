module ControllerHelper
  LOGTAG_MAX = 2**32

  def self.gen_logtag
    rand(LOGTAG_MAX)
  end # end def gen_logtag

  def self.create_entity_by_name_email(name, email)
    return_obj = nil
    begin
      # Create propertyId
      new_person = Person.create(:name => name, :email => email)
      return_obj = new_person
      raise Exception if new_person.errors
      # Create entity
      new_entity = Entity.create(:property_document_id => new_person.id)
      return_obj = new_person
      raise Exception if new_entity.errors
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
