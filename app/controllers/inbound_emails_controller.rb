require 'validators'
require 'controller_helper'

class InboundEmailsController < ApplicationController
  include ControllerHelper
Rails.logger.level = Logger::DEBUG

  # Incoming email parser specific fields
  # GET /inbound_emails
  # GET /inbound_emails.xml
  def index
    @inbound_emails = InboundEmail.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inbound_emails }
    end
  end

  # GET /inbound_emails/1
  # GET /inbound_emails/1.xml
  def show
    @inbound_email = InboundEmail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @inbound_email }
    end
  end

  # GET /inbound_emails/new
  # GET /inbound_emails/new.xml
  def new
    @inbound_email = InboundEmail.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @inbound_email }
    end
  end

  # GET /inbound_emails/1/edit
  def edit
    @inbound_email = InboundEmail.find(params[:id])
  end

  def create_common
    logtag = ControllerHelper.gen_logtag
     # Stores objs that causes problem except inbound_email
     # which is handled by different error handler in :action => new
     # view
     @error_obj_arr = []
puts "InboundEmail, create:#{params[:inbound_email].inspect}"
    # If the inbound_email was created using the interface then
    # it will keys like "commit", etc and the hash for the inbound_email
    # is stored using :inbound_email key
    inbound_email_params = params[:inbound_email]
    # If inbound_email was created using external mechanims, e.g.,
    # sendgrid, then there is no :inbound_email key so we
    # use the params directly
    inbound_email_params ||= params
    # We can also based on certain values, e.g., smtp ip or header
    # fields decide which field_mapper to get, but we need at least
    # one field that is guarateed there, for sendgrid, we can use headers
    field_mapper_type = nil
    if inbound_email_params[:headers].match /sendgrid.meant.it/
      field_mapper_type = InboundEmailFieldMapperFactory::SENDGRID
    end # end if inbound_email_params ...
    field_mapper = InboundEmailFieldMapperFactory.get_inbound_email_field_mapper(field_mapper_type)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, field_mapper_type:#{field_mapper_type}")
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, field_mapper:#{field_mapper.inspect}")
    @inbound_email = InboundEmail.new(
      :headers => inbound_email_params[field_mapper[:headers]],
      :body_text => inbound_email_params[field_mapper[:body_text]],
      :body_html => inbound_email_params[field_mapper[:body_html]],
      :from => inbound_email_params[field_mapper[:from]],
      :to => inbound_email_params[field_mapper[:to]],
      :subject => inbound_email_params[field_mapper[:subject]],
      :cc => inbound_email_params[field_mapper[:cc]],
      :dkim => inbound_email_params[field_mapper[:dkim]],
      :spf => inbound_email_params[field_mapper[:spf]],
      :envelope => inbound_email_params[field_mapper[:envelope]],
      :charsets => inbound_email_params[field_mapper[:charsets]],
      :spam_score => inbound_email_params[field_mapper[:spam_score]],
      :spam_report => inbound_email_params[field_mapper[:spam_report]],
      :attachment_count => inbound_email_params[field_mapper[:attachment_count]]
    )

    unless @inbound_email.save
      error_display("Error creating inbound_email:#{@inbound_email.errors}", @inbound_email.errors, :error, logtag) 
      return
    end # end unless @inbound_email ...
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created inbound_email with id:#{@inbound_email.id}")
    sender_str = inbound_email_params[field_mapper[:from]]
    logger.debug("#{File.basename(__FILE__)}:#{self.class},create:#{logtag}, sender_str = inbound_email_params[field_mapper[:from]]:#{inbound_email_params[field_mapper[:from]]}")
    # Parse sender string to derive nick and email address
    sender_str_match_arr = sender_str.match(/(.*)<(.*)>/)
    sender_nick_str = sender_str_match_arr[1].strip if !sender_str_match_arr.nil?
    sender_str = sender_str_match_arr[2] if !sender_str_match_arr.nil?
    sender_nick_str ||= sender_str
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, sender_str:#{sender_str}")
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, sender_nick_str:#{sender_nick_str}")
    sender_email_addr = inbound_email_params[field_mapper[:to]]
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, sender_email_addr = inbound_email_params[field_mapper[:to]]:#{inbound_email_params[field_mapper[:to]]}")
    message_type_str = ControllerHelper.parse_message_type_from_email_addr(sender_email_addr, logtag)
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, message_type_str:#{message_type_str}")
    # Create sender EndPoint
    @sender_pii = Pii.find_or_create_by_pii_value_and_pii_type(sender_str, PiiTypeValidator::PII_TYPE_EMAIL) do |pii_obj|
      logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created sender_pii")
    end # end Pii.find_or_create_by_pii ...
    unless @sender_pii.errors.empty?
      @error_obj_arr << @sender_pii
      error_display("Error creating sender_pii '#{sender_str}':#{@sender_pii.errors}", @sender_pii.errors, :error, logtag)
      return
    end # unless @sender_pii.errors.empty?
    @sender_endPoint = @sender_pii.endPoint
    if @sender_endPoint.nil?
      @sender_endPoint = @sender_pii.create_endPoint(:nick => sender_nick_str, :start_time => Time.now)
      # Save the association
      @sender_endPoint.pii = @sender_pii
      @sender_endPoint.nick = sender_nick_str
      @sender_endPoint.creator_endpoint_id = @sender_endPoint.id
      unless @sender_endPoint.save
       @error_obj_arr << @sender_endPoint
        error_display("Error creating @sender_endPoint '#{@sender_endPoint.inspect}:#{@sender_endPoint.errors}", @sender_endPoint.errors, :error, logtag)
        return
      end # end unless @sender_endPoint.save
      logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, acquired sender_endPoint with id:#{@sender_endPoint.id}")
    end # end if @sender_endPoint.nil?
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, @sender_endPoint.entities:#{@sender_endPoint.entities}")
    if @sender_endPoint.entities.empty?
      # Create person
      @person = ControllerHelper.find_or_create_person_by_email(sender_nick_str, sender_str, logtag)
      unless @person.errors.empty?
        @error_obj_arr << @person
        error_display("Error creating person 'name:#{sender_nick_str}, email:#{sender_str}:#{@person.errors}", @person.errors, :error, logtag)
        return
      end # end unless @person.errors.empty?
      # Create an entity having property_document with sender email
      entity_collection = Entity.where("property_document_id = ?", @person.id.to_s)
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, for @person.id:#{@person.id}, entity_collection.inspect:#{entity_collection.inspect}")
      if entity_collection.empty?
        @entity = Entity.create(:property_document_id => @person.id)
      else
        @entity = entity_collection[0]
      end # end if entity_collection.empty?
      unless @entity.errors.empty?
        @error_obj_arr << @entity
        error_display("Error creating entity 'property_document_id:#{@person.id}':#{@entity.errors}", @entity.errors, :error, logtag)
        return
      end # end unless @entity.errors.empty?
      # Link entity to the @sender_endPoint
      if @entity.errors.empty?
        # We cannot just do @entity.endPoints << @sender_endPoint
        # because EntityEndPointRels.verification_type must not be null
        @entityEndPointRel1 = @entity.entityEndPointRels.create(:verification_type => VerificationTypeValidator::VERIFICATION_TYPE_EMAIL)
        @entityEndPointRel1.endpoint_id = @sender_endPoint.id
        unless @entityEndPointRel1.save
          @error_obj_arr << @entityEndPointRel1
          error_display("Error creating entityEndPointRel 'entity:#{@entity.name} relate @sender_endPoint:#{@sender_endPoint.id}':#{@entityEndPointRel1.errors}", @entityEndPointRel1.errors, :error, logtag)
          return
        end # end unless @entityEndPointRel1.save
      end # end if @entity.errors.empty?
    end # end if @sender_endPoint.entities.empty?
    # Look at subject if it's not nil
    # else use body_text
    input_str = inbound_email_params[field_mapper[:subject]]
    if input_str.nil? or input_str.empty?
      input_str = inbound_email_params[field_mapper[:body_text]]
    end # end if input_str.nil? or input_str.empty?
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, input_str:#{input_str}")
    # Decide what to do on nick, pii, message, tags...
    # Case:
    # nick (yes) :xxx (no) ;yyy (*) tags (yes): sender (global id-able source)
    # Dup input_str in case we need it
    # Don't manipulate the original input_str since it is used
    # to re-populate form on failures
    input_str_dup = input_str.dup
    meantItInput_hash = ControllerHelper.parse_meant_it_input(input_str_dup, logtag)
    message_str = meantItInput_hash[ControllerHelper::MEANT_IT_INPUT_MESSAGE]
    receiver_pii_str = meantItInput_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    receiver_nick_str = meantItInput_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    tag_str_arr = meantItInput_hash[ControllerHelper::MEANT_IT_INPUT_TAGS]

    # Four conditions:
    # 1. receiver_pii_str: empty, receiver_nick_str: empty
    # 2. receiver_pii_str: yes, receiver_nick_str: yes
    # 3. receiver_pii_str: yes, receiver_nick_str: empty
    # 4. receiver_pii_str: empty, receiver_nick_str: yes

    # Case 1. receiver_pii_str: empty, receiver_nick_str: empty
    # Cannot identify receiver
    if (receiver_pii_str.nil? or receiver_pii_str.empty?) and (receiver_nick_str.nil? or receiver_nick_str.empty?)
      @receiver_endPoint.new
      @error_obj_arr << @receiver_endPoint
      error_display("Error finding/creating @receiver_endPoint, both receiver_nick and receiver_pii are empty", @receiver_endPoint.errors, :error, logtag)
      return
    end # end Case 1. ... if (receiver_pii_str.nil? or  ...

    # Case 2. receiver_pii_str: yes, receiver_nick_str: yes
    # or
    # Case 3. receiver_pii_str: yes, receiver_nick_str: empty
    # We need to find_or_create the receiver_pii
    if (
        ((!receiver_pii_str.nil? and !receiver_pii_str.empty?) and (!receiver_nick_str.nil? and !receiver_nick_str.empty?)) or
        ((!receiver_pii_str.nil? and !receiver_pii_str.empty?) and (receiver_nick_str.nil? or receiver_nick_str.empty?))
       )
      # Create receiver pii if it does not possess one
      @receiver_pii = Pii.find_or_create_by_pii_value_and_pii_type(receiver_pii_str, PiiTypeValidator::PII_TYPE_EMAIL) do |pii_obj|
        logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created receiver_pii")
      end # end Pii.find_or_create_by_pii ...
      unless @receiver_pii.errors.empty?
        @error_obj_arr << @receiver_pii
        error_display("Error creating receiver_pii '#{receiver_pii_str}'",  @receiver_pii.errors, :error, logtag) 
        return
      end # end unless @receiver_pii.errors.empty?
    end # end get @receiver_pii ... if (receiver_pii_str.nil? or  ...

    # Case 2. receiver_pii_str: yes, receiver_nick_str: yes
    # or
    # Case 4. receiver_pii_str: empty, receiver_nick_str: yes
    # Need to find EndPoint
    if (
        ((!receiver_pii_str.nil? and !receiver_pii_str.empty?) and (!receiver_nick_str.nil? and !receiver_nick_str.empty?)) or
        ((receiver_pii_str.nil? or receiver_pii_str.empty?) and (!receiver_nick_str.nil? and !receiver_nick_str.empty?))
       )
      @receiver_endPoint = EndPoint.find_or_create_by_nick_and_creator_endpoint_id(:nick => receiver_nick_str, :creator_endpoint_id => @sender_endPoint.id, :start_time => Time.now) do |ep_obj|
        logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created receiver_endPoint")
      end # end @receiver_endPoint ...
    end # end Cases 2 and 4 ...

    # For Case 2. receiver_pii_str: yes, receiver_nick_str: yes 
    # and they have been linked before, we check validity
    # If @receiver_pii and @receiver_endPoints exist and there were no 
    # errors creating them they must point to each other if they
    # are not pointing to nil.
    if (!@receiver_pii.nil? and !@receiver_pii.errors.any?) and (!@receiver_endPoint.nil? and !@receiver_endPoint.errors.any?)
      unless @receiver_pii.endPoint == @receiver_endPoint and @receiver_endPoint.pii = @receiver_pii
        @error_obj_arr << @receiver_endPoint
        error_display("receiver_endPoint '#{@receiver_endPoint.nick}' already has pii_value '#{@receiver_endPoint.pii.pii_value}' so it cannot accept new value '#{receiver_pii_str}'",  @receiver_endPoint.errors, :error, logtag) 
        return
      end # end unless @receiver_pii.endPoint == @receiver_endPoint and @receiver_endPoint.pii = @receiver_pii
    end # end if (!@receiver_pii.nil? and !@receiver_pii.errors.any?)  ...

    # For Case 3. receiver_pii_str: yes, receiver_nick_str: empty
    # we create endPoint and tie receiver_pii to it
    if ((!receiver_pii_str.nil? and !receiver_pii_str.empty?) and (receiver_nick_str.nil? or receiver_nick_str.empty?))
      @receiver_endPoint = EndPoint.create(:creator_endpoint_id => @sender_endPoint.id, :start_time => Time.now)
      @receiver_endPoint.pii = @receiver_pii
      unless @receiver_endPoint.save
        @error_obj_arr << @receiver_endPoint
        error_display("Error saving receiver_pii '#{receiver_pii.inspect}' to receiver_endPoint '{receiver_endPoint.inspect}'",  @receiver_endPoint.errors, :error, logtag) 
        return
      end # end unless @receiver_endPoint.save
    end # end if ((!receiver_pii_str.nil? and !receiver_pii_str.empty?)  ...
    
    # For Case 4. receiver_pii_str: empty, receiver_nick_str: yes
    # We already have endPoint

    # At this stage all Case 2, 3, 4 have @receiver_endPoints

#20110627    @receiver_endPoint = EndPoint.find_or_create_by_nick_and_creator_endpoint_id(:nick => receiver_nick_str, :creator_endpoint_id => @sender_endPoint.id, :start_time => Time.now) do |ep_obj|
#20110627      logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created receiver_endPoint")
#20110627    end # end EndPoint.find_or_create_by ...
#20110627    if @receiver_endPoint.pii
#20110627      # Ensure the existing pii is the same otherwise flag error
#20110627      unless @receiver_endPoint.pii.pii_value == receiver_pii_str or receiver_pii_str.nil? or receiver_pii_str.empty?
#20110627        @error_obj_arr << @receiver_endPoint
#20110627        error_display("receiver_endPoint '#{@receiver_endPoint.nick}' already has pii_value '#{@receiver_endPoint.pii.pii_value}' so it cannot accept new value '#{receiver_pii_str}'",  @receiver_endPoint.errors, :error, logtag) 
#20110627        return
#20110627      end # end if @receiver_endPoint.pii != ...
#20110627AA    elsif !receiver_pii_str.nil? and !receiver_pii_str.empty?
#20110627    else
#20110627      # Create receiver pii if it does not possess one
#20110627      @receiver_pii = Pii.find_or_create_by_pii_value_and_pii_type(receiver_pii_str, PiiTypeValidator::PII_TYPE_EMAIL) do |pii_obj|
#20110627        logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created receiver_pii")
#20110627      end # end Pii.find_or_create_by_pii ...
#20110627AA      unless @receiver_pii.errors.empty? or receiver_pii_str.nil? or receiver_pii_str.empty?
#20110627      unless @receiver_pii.errors.empty?
#20110627        @error_obj_arr << @receiver_pii
#20110627        error_display("Error creating receiver_pii '#{receiver_pii_str}'",  @receiver_pii.errors, :error, logtag) 
#20110627        return
#20110627      end # end unless @receiver_pii.errors.empty?
#20110627      @receiver_endPoint.pii = @receiver_pii
#20110627      unless @receiver_endPoint.save
#20110627        @error_obj_arr << @receiver_endPoint
#20110627        error_display("Error saving receiver_pii '#{receiver_pii.inspect}' to receiver_endPoint '{receiver_endPoint.inspect}'",  @receiver_endPoint.errors, :error, logtag) 
#20110627        return
#20110627      end # end unless @receiver_endPoint.save
#20110627    end # end if @receiver_endPoint.pii

    unless @receiver_endPoint.errors.empty?
      @error_obj_arr << @receiver_endPoint
      error_display("Error creating @receiver_endPoint '#{@receiver_endPoint.inspect}':#{@receiver_endPoint.errors}", @receiver_endPoint.errors, :error, logtag)
      return
    end # end unless @receiver_endPoint.errors.empty?
    if !@receiver_endPoint.nil?
      # Add tags that are not yet attached to the @receiver_endPoint
      existing_tag_str_arr = @receiver_endPoint.tags.collect { |tag_elem| tag_elem.name }
      yet_2b_associated_tag_str_arr = (existing_tag_str_arr - tag_str_arr) + (tag_str_arr - existing_tag_str_arr)
      yet_2b_associated_tag_str_arr.each { |tag_str_elem|
        @new_tag = Tag.find_or_create_by_name(tag_str_elem) do |tag_obj|
          logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created tag:#{tag_str_elem}")
        end # end Tag.find_or_create_by ...
        unless @new_tag.errors.empty?
          @error_obj_arr << @new_tag
          error_display("Error creating new_tag '#{tag_str_elem}':#{@new_tag.errors}", @new_tag.errors, :error, logtag)
          return
        end # end unless @new_tag.errors.empty?
        @receiver_endPoint.tags << @new_tag
      } # end tag_str_arr.each ...
    end # end if !@receiver_endPoint.nil?
    # Create meant_it rel
    if !@sender_endPoint.nil? and !@receiver_endPoint.nil? and !@inbound_email.nil?
      @meantItRel = @sender_endPoint.srcMeantItRels.create(:message_type => message_type_str, :message => message_str, :src_endpoint_id => @sender_endPoint.id, :dst_endpoint_id => @receiver_endPoint.id, :inbound_email_id => @inbound_email.id)
      unless @meantItRel.errors.empty?
        @error_obj_arr << @meantItRel
        error_display("Error creating meantItRel 'sender_endPoint.id:#{@sender_endPoint.id}, message_type:#{@meantItRel.message_type}, receiver_endPoint.id#{receiver_endPoint.id}':#{@meantItRel.errors}", @meantItRel.errors, :error, logtag)
        return
      end # end unless @meantItRel.errors.empty?
      if @meantItRel.errors.empty?
        if message_type_str == MeantItMessageTypeValidator::MEANT_IT_MESSAGE_OTHER
          # Call mood reasoner
          # CODE!!!!! Implement this in ControllerHelper
        else
          logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}: creating mood using message_type_str:#{message_type_str}")
          @new_mood_tag = Tag.find_or_create_by_name_and_desc(message_type_str, MeantItMoodTagRel::MOOD_TAG_TYPE) do |tag_obj|
            logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created mood_tag:#{message_type_str}")
          end # end Tag.find_or_create_by ...
          unless @new_mood_tag.errors.empty?
            @error_obj_arr << @new_mood_tag
            error_display("Error creating new_mood_tag '#{message_type_str}':#{@new_mood_tag.errors}", @new_mood_tag.errors, :error, logtag)
            return
          end # end unless @new_mood_tag.errors.empty?
          @meantItRel.tags << @new_mood_tag
        end # end if message_type_str == MeantItMessageTypeValidator:: ...
      end # end if @meantItRel.errors.empty?
    end # end if !@sender_endPoint.nil? and !@receiver_endPoint.nil? and !@inbound_email.nil?
  end # end def create_common

  # POST /inbound_emails
  # POST /inbound_emails.xml
  def create
    logtag = ControllerHelper.gen_logtag
     # Stores objs that causes problem except inbound_email
     # which is handled by different error handler in :action => new
     # view
     @error_obj_arr = []
puts "InboundEmail, create:#{params[:inbound_email].inspect}"
    # If the inbound_email was created using the interface then
    # it will keys like "commit", etc and the hash for the inbound_email
    # is stored using :inbound_email key
    inbound_email_params = params[:inbound_email]
    # If inbound_email was created using external mechanims, e.g.,
    # sendgrid, then there is no :inbound_email key so we
    # use the params directly
    inbound_email_params ||= params
    # We can also based on certain values, e.g., smtp ip or header
    # fields decide which field_mapper to get, but we need at least
    # one field that is guarateed there, for sendgrid, we can use headers
    field_mapper_type = nil
    if inbound_email_params[:headers].match /sendgrid.meant.it/
      field_mapper_type = InboundEmailFieldMapperFactory::SENDGRID
    end # end if inbound_email_params ...
    field_mapper = InboundEmailFieldMapperFactory.get_inbound_email_field_mapper(field_mapper_type)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, field_mapper_type:#{field_mapper_type}")
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, field_mapper:#{field_mapper.inspect}")
    @inbound_email = InboundEmail.new(
      :headers => inbound_email_params[field_mapper[:headers]],
      :body_text => inbound_email_params[field_mapper[:body_text]],
      :body_html => inbound_email_params[field_mapper[:body_html]],
      :from => inbound_email_params[field_mapper[:from]],
      :to => inbound_email_params[field_mapper[:to]],
      :subject => inbound_email_params[field_mapper[:subject]],
      :cc => inbound_email_params[field_mapper[:cc]],
      :dkim => inbound_email_params[field_mapper[:dkim]],
      :spf => inbound_email_params[field_mapper[:spf]],
      :envelope => inbound_email_params[field_mapper[:envelope]],
      :charsets => inbound_email_params[field_mapper[:charsets]],
      :spam_score => inbound_email_params[field_mapper[:spam_score]],
      :spam_report => inbound_email_params[field_mapper[:spam_report]],
      :attachment_count => inbound_email_params[field_mapper[:attachment_count]]
    )

    unless @inbound_email.save
      error_display("Error creating inbound_email:#{@inbound_email.errors}", @inbound_email.errors, :error, logtag) 
      return
    end # end unless @inbound_email ...
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created inbound_email with id:#{@inbound_email.id}")
    sender_str = inbound_email_params[field_mapper[:from]]
    logger.debug("#{File.basename(__FILE__)}:#{self.class},create:#{logtag}, sender_str = inbound_email_params[field_mapper[:from]]:#{inbound_email_params[field_mapper[:from]]}")
    # Parse sender string to derive nick and email address
    sender_str_match_arr = sender_str.match(/(.*)<(.*)>/)
    sender_nick_str = sender_str_match_arr[1].strip if !sender_str_match_arr.nil?
    sender_str = sender_str_match_arr[2] if !sender_str_match_arr.nil?
    sender_nick_str ||= sender_str
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, sender_str:#{sender_str}")
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, sender_nick_str:#{sender_nick_str}")
    sender_email_addr = inbound_email_params[field_mapper[:to]]
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, sender_email_addr = inbound_email_params[field_mapper[:to]]:#{inbound_email_params[field_mapper[:to]]}")
    message_type_str = ControllerHelper.parse_message_type_from_email_addr(sender_email_addr, logtag)
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, message_type_str:#{message_type_str}")
    # Create sender EndPoint
    @sender_pii = Pii.find_or_create_by_pii_value_and_pii_type(sender_str, PiiTypeValidator::PII_TYPE_EMAIL) do |pii_obj|
      logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created sender_pii")
    end # end Pii.find_or_create_by_pii ...
    unless @sender_pii.errors.empty?
       @error_obj_arr << @sender_pii
      error_display("Error creating sender_pii '#{sender_str}':#{@sender_pii.errors}", @sender_pii.errors, :error, logtag)
      return
    end # unless @sender_pii.errors.empty?
    @sender_endPoint = @sender_pii.endPoint
    if @sender_endPoint.nil?
      @sender_endPoint = @sender_pii.create_endPoint(:nick => sender_nick_str, :start_time => Time.now)
      # Save the association
      @sender_endPoint.pii = @sender_pii
      @sender_endPoint.nick = sender_nick_str
      @sender_endPoint.creator_endpoint_id = @sender_endPoint.id
      unless @sender_endPoint.save
       @error_obj_arr << @sender_endPoint
        error_display("Error creating @sender_endPoint '#{@sender_endPoint.inspect}:#{@sender_endPoint.errors}", @sender_endPoint.errors, :error, logtag)
        return
      end # end unless @sender_endPoint.save
      logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, acquired sender_endPoint with id:#{@sender_endPoint.id}")
    end # end if @sender_endPoint.nil?
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, @sender_endPoint.entities:#{@sender_endPoint.entities}")
    if @sender_endPoint.entities.empty?
      # Create person
      @person = ControllerHelper.find_or_create_person_by_email(sender_nick_str, sender_str, logtag)
      unless @person.errors.empty?
        @error_obj_arr << @person
        error_display("Error creating person 'name:#{sender_nick_str}, email:#{sender_str}:#{@person.errors}", @person.errors, :error, logtag)
        return
      end # end unless @person.errors.empty?
      # Create an entity having property_document with sender email
      entity_collection = Entity.where("property_document_id = ?", @person.id.to_s)
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, for @person.id:#{@person.id}, entity_collection.inspect:#{entity_collection.inspect}")
      if entity_collection.empty?
        @entity = Entity.create(:property_document_id => @person.id)
      else
        @entity = entity_collection[0]
      end # end if entity_collection.empty?
      unless @entity.errors.empty?
        @error_obj_arr << @entity
        error_display("Error creating entity 'property_document_id:#{@person.id}':#{@entity.errors}", @entity.errors, :error, logtag)
        return
      end # end unless @entity.errors.empty?
      # Link entity to the @sender_endPoint
      if @entity.errors.empty?
        # We cannot just do @entity.endPoints << @sender_endPoint
        # because EntityEndPointRels.verification_type must not be null
        @entityEndPointRel1 = @entity.entityEndPointRels.create(:verification_type => VerificationTypeValidator::VERIFICATION_TYPE_EMAIL)
        @entityEndPointRel1.endpoint_id = @sender_endPoint.id
        unless @entityEndPointRel1.save
          @error_obj_arr << @entityEndPointRel1
          error_display("Error creating entityEndPointRel 'entity:#{@entity.name} relate @sender_endPoint:#{@sender_endPoint.id}':#{@entityEndPointRel1.errors}", @entityEndPointRel1.errors, :error, logtag)
          return
        end # end unless @entityEndPointRel1.save
      end # end if @entity.errors.empty?
    end # end if @sender_endPoint.entities.empty?
    # Look at subject if it's not nil
    # else use body_text
    input_str = inbound_email_params[field_mapper[:subject]]
    if input_str.nil? or input_str.empty?
      input_str = inbound_email_params[field_mapper[:body_text]]
    end # end if input_str.nil? or input_str.empty?
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, input_str:#{input_str}")
    # Decide what to do on nick, pii, message, tags...
    # Case:
    # nick (yes) :xxx (no) ;yyy (*) tags (yes): sender (global id-able source)
    # Dup input_str in case we need it
    # Don't manipulate the original input_str since it is used
    # to re-populate form on failures
    input_str_dup = input_str.dup
    meantItInput_hash = ControllerHelper.parse_meant_it_input(input_str_dup, logtag)
    message_str = meantItInput_hash[ControllerHelper::MEANT_IT_INPUT_MESSAGE]
    receiver_pii_str = meantItInput_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    receiver_nick_str = meantItInput_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    tag_str_arr = meantItInput_hash[ControllerHelper::MEANT_IT_INPUT_TAGS]
    @receiver_endPoint = EndPoint.find_or_create_by_nick_and_creator_endpoint_id(:nick => receiver_nick_str, :creator_endpoint_id => @sender_endPoint.id, :start_time => Time.now) do |ep_obj|
      logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created receiver_endPoint")
    end # end EndPoint.find_or_create_by ...
    if @receiver_endPoint.pii
      # Ensure the existing pii is the same otherwise flag error
      unless @receiver_endPoint.pii.pii_value == receiver_pii_str or receiver_pii_str.nil? or receiver_pii_str.empty?
        @error_obj_arr << @receiver_endPoint
        error_display("receiver_endPoint '#{@receiver_endPoint.nick}' already has pii_value '#{@receiver_endPoint.pii.pii_value}' so it cannot accept new value '#{receiver_pii_str}'",  @receiver_endPoint.errors, :error, logtag) 
        return
      end # end if @receiver_endPoint.pii != ...
    else
      # Create receiver pii if it does not possess one
      @receiver_pii = Pii.find_or_create_by_pii_value_and_pii_type(receiver_pii_str, PiiTypeValidator::PII_TYPE_EMAIL) do |pii_obj|
        logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created receiver_pii")
      end # end Pii.find_or_create_by_pii ...
      unless @receiver_pii.errors.empty? or receiver_pii_str.nil? or receiver_pii_str.empty?
        @error_obj_arr << @receiver_pii
        error_display("Error creating receiver_pii '#{receiver_pii_str}'",  @receiver_pii.errors, :error, logtag) 
        return
      end # end unless @receiver_pii.errors.empty?
      @receiver_endPoint.pii = @receiver_pii
      unless @receiver_endPoint.save
        @error_obj_arr << @receiver_endPoint
        error_display("Error saving receiver_pii '#{@receiver_pii.inspect}' to receiver_endPoint '{@receiver_endPoint.inspect}'",  @receiver_endPoint.errors, :error, logtag) 
        return
      end # end unless @receiver_endPoint.save
    end # end if @receiver_endPoint.pii
    unless @receiver_endPoint.errors.empty?
      @error_obj_arr << @receiver_endPoint
      error_display("Error creating @receiver_endPoint '#{@receiver_endPoint.inspect}':#{@receiver_endPoint.errors}", @receiver_endPoint.errors, :error, logtag)
      return
    end # end unless @receiver_endPoint.errors.empty?
    if !@receiver_endPoint.nil?
      # Add tags that are not yet attached to the @receiver_endPoint
      existing_tag_str_arr = @receiver_endPoint.tags.collect { |tag_elem| tag_elem.name }
      yet_2b_associated_tag_str_arr = (existing_tag_str_arr - tag_str_arr) + (tag_str_arr - existing_tag_str_arr)
      yet_2b_associated_tag_str_arr.each { |tag_str_elem|
        @new_tag = Tag.find_or_create_by_name(tag_str_elem) do |tag_obj|
          logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created tag:#{tag_str_elem}")
        end # end Tag.find_or_create_by ...
        unless @new_tag.errors.empty?
          @error_obj_arr << @new_tag
          error_display("Error creating new_tag '#{tag_str_elem}':#{@new_tag.errors}", @new_tag.errors, :error, logtag)
          return
        end # end unless @new_tag.errors.empty?
        @receiver_endPoint.tags << @new_tag
      } # end tag_str_arr.each ...
    end # end if !@receiver_endPoint.nil?
    # Create meant_it rel
    if !@sender_endPoint.nil? and !@receiver_endPoint.nil? and !@inbound_email.nil?
      @meantItRel = @sender_endPoint.srcMeantItRels.create(:message_type => message_type_str, :message => message_str, :src_endpoint_id => @sender_endPoint.id, :dst_endpoint_id => @receiver_endPoint.id, :inbound_email_id => @inbound_email.id)
      unless @meantItRel.errors.empty?
        @error_obj_arr << @meantItRel
        error_display("Error creating meantItRel 'sender_endPoint.id:#{@sender_endPoint.id}, message_type:#{@meantItRel.message_type}, receiver_endPoint.id#{receiver_endPoint.id}':#{@meantItRel.errors}", @meantItRel.errors, :error, logtag)
        return
      end # end unless @meantItRel.errors.empty?
      if @meantItRel.errors.empty?
        if message_type_str == MeantItMessageTypeValidator::MEANT_IT_MESSAGE_OTHER
          # Call mood reasoner
          # CODE!!!!! Implement this in ControllerHelper
        else
          logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}: creating mood using message_type_str:#{message_type_str}")
          @new_mood_tag = Tag.find_or_create_by_name_and_desc(message_type_str, MeantItMoodTagRel::MOOD_TAG_TYPE) do |tag_obj|
            logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created mood_tag:#{message_type_str}")
          end # end Tag.find_or_create_by ...
          unless @new_mood_tag.errors.empty?
            @error_obj_arr << @new_mood_tag
            error_display("Error creating new_mood_tag '#{message_type_str}':#{@new_mood_tag.errors}", @new_mood_tag.errors, :error, logtag)
            return
          end # end unless @new_mood_tag.errors.empty?
          @meantItRel.tags << @new_mood_tag
        end # end if message_type_str == MeantItMessageTypeValidator:: ...
      end # end if @meantItRel.errors.empty?
    end # end if !@sender_endPoint.nil? and !@receiver_endPoint.nil? and !@inbound_email.nil?
    respond_to do |format|
      format.html { redirect_to(@inbound_email, :notice => 'Inbound email was successfully created.') }
      # Things that require 200 otherwise they'll keep resending, e.g.
      # sendgrid
      if self.request.path.match(/inbound_emails_200/)
        format.xml  { render :xml => @inbound_email, :status => :created }
      else
        format.xml  { render :xml => @inbound_email, :status => :created, :location => @inbound_email }
      end # end if self.request.path.match(/inbound_emails_200/)
puts "InboundEmail, @inbound_email.errors:#{@inbound_email.errors.inspect}"
    end
  end

  # PUT /inbound_emails/1
  # PUT /inbound_emails/1.xml
  def update
    @inbound_email = InboundEmail.find(params[:id])

    respond_to do |format|
      if @inbound_email.update_attributes(params[:inbound_email])
        format.html { redirect_to(@inbound_email, :notice => 'Inbound email was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @inbound_email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inbound_emails/1
  # DELETE /inbound_emails/1.xml
  def destroy
    @inbound_email = InboundEmail.find(params[:id])
    @inbound_email.destroy

    respond_to do |format|
      format.html { redirect_to(inbound_emails_url) }
      format.xml  { head :ok }
    end
  end

  private
    def error_display(message, errors, message_type =:error, logtag=nil)
      if @inbound_email.errors.any?
        if self.request.path.match(/inbound_emails_200/)
          logger.warn("#{File.basename(__FILE__)}:#{self.class}:e:#{logtag}: inbound email with params:#{message}, generated errors:#{errors.inspect}")
          # Problem with inbound_email saving, this is the fault
          # automated sender.  Only automated sender uses inbound_emails_200
          # Record this error
          @inbound_email_logs = InboundEmailLog.create(:params_txt => params.inspect.to_s, :error_msgs => message, :error_objs => @inbound_email.errors.inspect.to_s)
        else
          # We don't worry cause user will see error message
        end # end if self.request.path.match(/inbound_emails_200/)
      else
        logger.warn("#{File.basename(__FILE__)}:#{self.class}:e:#{logtag}: inbound email saved but controller processing resulted in message:#{message}, and errors:#{errors.inspect}")
        @inbound_email.error_msgs = message.to_s
        @inbound_email.error_objs = errors.inspect.to_s
        @inbound_email.save
      end # end if @inbound_email.errors.any?
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:error_display:#{logtag}: message:#{message}, errors:#{errors}, message_type:#{message_type}")
      flash[message_type] = message
      respond_to do |format|
        format.html { render :action => "new" }
        # Things that require 200 otherwise they'll keep resending, e.g.
        # sendgrid
        if self.request.path.match(/inbound_emails_200/)
          format.xml  { render :xml => errors, :status => 200 }
        else
          format.xml  { render :xml => errors, :status => :unprocessable_entity }
        end # end if self.request.path.match(/inbound_emails_200/)
      end # respond_to
    end # end def error_display
end
