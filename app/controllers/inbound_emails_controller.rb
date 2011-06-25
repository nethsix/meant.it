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
#AD      :headers => params["headers"],
      :headers => inbound_email_params[field_mapper[:headers]],
#AD      :body_text => params["text"],
      :body_text => inbound_email_params[field_mapper[:body_text]],
#AD      :body_html => inbound_email_params["html"],
      :body_html => inbound_email_params[field_mapper[:body_html]],
#AD      :from => params["from"],
      :from => inbound_email_params[field_mapper[:from]],
#AD      :to => params["to"],
      :to => inbound_email_params[field_mapper[:to]],
#AD      :subject => params["subject"],
      :subject => inbound_email_params[field_mapper[:subject]],
#AD      :cc => params["cc"],
      :cc => inbound_email_params[field_mapper[:cc]],
#AD      :dkim => params["dkim"],
      :dkim => inbound_email_params[field_mapper[:dkim]],
#AD      :spf => params["spf"],
      :spf => inbound_email_params[field_mapper[:spf]],
#AD      :envelope => params["envelope"],
      :envelope => inbound_email_params[field_mapper[:envelope]],
#AD      :charsets => params["charsets"],
      :charsets => inbound_email_params[field_mapper[:charsets]],
#AD      :spam_score => params["spam_score"],
      :spam_score => inbound_email_params[field_mapper[:spam_score]],
#AD      :spam_report => params["spam_report"],
      :spam_report => inbound_email_params[field_mapper[:spam_report]],
#AD      :attachment_count => params["attachments"]
      :attachment_count => inbound_email_params[field_mapper[:attachment_count]]
    )

#    error = false
#    error = true if !@inbound_email.save
#AB    error_display("Error creating inbound_email:#{@inbound_email.errors}", @inbound_email.errors) if !@inbound_email.save
    unless @inbound_email.save
#AA      flash[:error] = "Error creating inbound_email:#{@inbound_email.errors}"
      error_display("Error creating inbound_email:#{@inbound_email.errors}", @inbound_email.errors, :error, logtag) 
      return
    end # end unless @inbound_email ...
    sender_str = inbound_email_params[field_mapper[:from]]
    logger.debug("#{File.basename(__FILE__)}:#{self.class},create:#{logtag}, sender_str = inbound_email_params[field_mapper[:from]]:#{inbound_email_params[field_mapper[:from]]}")
    # Parse sender string to derive nick and email address
    sender_str_match_arr = sender_str.match(/(.*)<(.*)>/)
    sender_nick_str = sender_str_match_arr[1].strip if !sender_str_match_arr.nil?
    sender_str = sender_str_match_arr[2] if !sender_str_match_arr.nil?
    sender_nick_str ||= sender_str
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, sender_str:#{sender_str}")
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, sender_nick_str:#{sender_nick_str}")
    message_type_str = inbound_email_params[field_mapper[:to]]
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, message_type_str = inbound_email_params[field_mapper[:to]]:#{inbound_email_params[field_mapper[:to]]}")
    message_type_str_match_arr = nil
    message_type_str_match_arr = message_type_str.match /(.*)@.*/ if !message_type_str.nil?
    if message_type_str_match_arr.nil?
      message_type_str = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_THANK
    else
      message_type_str = MessageTypeMapper.get_message_type(message_type_str_match_arr[1])
    end # end if message_type_str.nil? or message_type_str.empty?
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, message_type_str:#{message_type_str}")
    # Create sender EndPoint
    @sender_pii = Pii.find_or_create_by_pii_value_and_pii_type(sender_str, PiiTypeValidator::PII_TYPE_EMAIL)
#AB    error_display("Error creating sender_pii '#{sender_str}':#{sender_pii.errors}", sender_pii.errors) if !sender_pii.errors.empty?
    unless @sender_pii.errors.empty?
       @error_obj_arr << @sender_pii
#AA      flash[:error] = "Error creating sender_pii '#{sender_str}':#{sender_pii.errors}"
      error_display("Error creating sender_pii '#{sender_str}':#{@sender_pii.errors}", @sender_pii.errors, :error, logtag)
      return
    end # unless @sender_pii.errors.empty?
    @sender_endPoint = @sender_pii.endPoint
    if @sender_endPoint.nil?
#      @inbound_email.errors += @sender_endPoint.errors
      @sender_endPoint = @sender_pii.create_endPoint(:nick => sender_nick_str, :start_time => Time.now)
      # Save the association
      @sender_endPoint.pii = @sender_pii
      @sender_endPoint.nick = sender_nick_str
      @sender_endPoint.creator_endpoint_id = @sender_endPoint.id
#AB      error_display("Error creating sender_endPoint '#{sender_endPoint.inspect}:#{sender_endPoint.errors}", sender_endPoint.errors) if !sender_endPoint.save
      unless @sender_endPoint.save
       @error_obj_arr << @sender_endPoint
#AA       flash[:error] = "Error creating sender_endPoint '#{sender_endPoint.inspect}:#{sender_endPoint.errors}"
        error_display("Error creating @sender_endPoint '#{@sender_endPoint.inspect}:#{@sender_endPoint.errors}", @sender_endPoint.errors, :error, logtag)
        return
      end # end unless @sender_endPoint.save
#      @inbound_email.errors =+ sender_endPoint.errors
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
#      @entity = ControllerHelper.create_entity_by_name_email(sender_nick_str, sender_str)
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
#AB        error_display("Error creating entity 'name:#{sender_nick_str}, email:#{sender_str}:#{entity.errors}", entity.errors) if !entity.errors.empty?
#      unless @entity.errors.empty?
#AA          flash[:error] = "Error creating entity 'name:#{sender_nick_str}, email:#{sender_str}:#{entity.errors}"
#        error_display("Error creating entity 'name:#{sender_nick_str}, email:#{sender_str}:#{@entity.errors}", @entity.errors, :error, logtag)
#        return
#      end # end unless @entity.errors.empty?
#        @inbound_email.errors =+ entity.errors
      # Link entity to the @sender_endPoint
      if @entity.errors.empty?
        # We cannot just do @entity.endPoints << @sender_endPoint
        # because EntityEndPointRels.verification_type must not be null
        @entityEndPointRel1 = @entity.entityEndPointRels.create(:verification_type => VerificationTypeValidator::VERIFICATION_TYPE_EMAIL)
        @entityEndPointRel1.endpoint_id = @sender_endPoint.id
#AB          error_display("Error creating entityEndPointRel 'entity:#{entity.name} relate sender_endPoint:#{sender_endPoint.id}':#{entityEndPointRel1.errors}", entityEndPointRel1.errors) if !entityEndPointRel1.save
        unless @entityEndPointRel1.save
          @error_obj_arr << @entityEndPointRel1
#AA            flash[:error] = "Error creating entityEndPointRel 'entity:#{entity.name} relate sender_endPoint:#{sender_endPoint.id}':#{entityEndPointRel1.errors}"
          error_display("Error creating entityEndPointRel 'entity:#{@entity.name} relate @sender_endPoint:#{@sender_endPoint.id}':#{@entityEndPointRel1.errors}", @entityEndPointRel1.errors, :error, logtag)
          return
        end # end unless @entityEndPointRel1.save
#          @inbound_email.errors =+ entityEndPointRel1.errors
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
    @receiver_endPoint = EndPoint.find_or_create_by_nick_and_creator_endpoint_id(:nick => receiver_nick_str, :creator_endpoint_id => @sender_endPoint.id, :start_time => Time.now)
    if @receiver_endPoint.pii
      # Ensure the existing pii is the same otherwise flag error
      unless @receiver_endPoint.pii.pii_value == receiver_pii_str or receiver_pii_str.nil? or receiver_pii_str.empty?
        @error_obj_arr << @receiver_endPoint
        error_display("receiver_endPoint '#{@receiver_endPoint.nick}' already has pii_value '#{@receiver_endPoint.pii.pii_value}' so it cannot accept new value '#{receiver_pii_str}'",  @receiver_endPoint.errors, :error, logtag) 
        return
      end # end if @receiver_endPoint.pii != ...
    else
      # Create receiver pii if it does not possess one
      @receiver_pii = Pii.find_or_create_by_pii_value_and_pii_type(receiver_pii_str, PiiTypeValidator::PII_TYPE_EMAIL)
      unless @receiver_pii.errors.empty? or receiver_pii_str.nil? or receiver_pii_str.empty?
        @error_obj_arr << @receiver_pii
        error_display("Error creating receiver_pii '#{receiver_pii_str}'",  @receiver_pii.errors, :error, logtag) 
        return
      end # end unless @receiver_pii.errors.empty?
      @receiver_endPoint.pii = @receiver_pii
      unless @receiver_endPoint.save
        @error_obj_arr << @receiver_endPoint
        error_display("Error saving receiver_pii '#{receiver_pii.inspect}' to receiver_endPoint '{receiver_endPoint.inspect}'",  @receiver_endPoint.errors, :error, logtag) 
        return
      end # end unless @receiver_endPoint.save
    end # end if @receiver_endPoint.pii
#AB    error_display("Error creating receiver_endPoint '#{receiver_endPoint.inspect}':#{receiver_endPoint.errors}", receiver_endPoint.errors) if !receiver_endPoint.errors.empty?
    unless @receiver_endPoint.errors.empty?
      @error_obj_arr << @receiver_endPoint
#AA      flash[:error] = "Error creating receiver_endPoint '#{receiver_endPoint.inspect}':#{receiver_endPoint.errors}"
      error_display("Error creating @receiver_endPoint '#{@receiver_endPoint.inspect}':#{@receiver_endPoint.errors}", @receiver_endPoint.errors, :error, logtag)
      return
    end # end unless @receiver_endPoint.errors.empty?
#    @inbound_email.errors =+ receiver_endPoint.errors
    if !@receiver_endPoint.nil?
      # Add tags that are not yet attached to the @receiver_endPoint
      existing_tag_str_arr = @receiver_endPoint.tags.collect { |tag_elem| tag_elem.name }
      yet_2b_associated_tag_str_arr = (existing_tag_str_arr - tag_str_arr) + (tag_str_arr - existing_tag_str_arr)
      yet_2b_associated_tag_str_arr.each { |tag_str_elem|
        @new_tag = Tag.find_or_create_by_name(tag_str_elem)
#AB        error_display("Error creating new_tag '#{tag_str_elem}':#{new_tag.errors}", new_tag.errors) if !new_tag.errors.empty?
        unless @new_tag.errors.empty?
          @error_obj_arr << @new_tag
#AA          flash[:error] = "Error creating new_tag '#{tag_str_elem}':#{new_tag.errors}"
          error_display("Error creating new_tag '#{tag_str_elem}':#{@new_tag.errors}", @new_tag.errors, :error, logtag)
          return
        end # end unless @new_tag.errors.empty?
        @receiver_endPoint.tags << @new_tag
      } # end tag_str_arr.each ...
    end # end if !@receiver_endPoint.nil?
    # Create meant_it rel
    if !@sender_endPoint.nil? and !@receiver_endPoint.nil? and !@inbound_email.nil?
      @meantItRel = @sender_endPoint.srcMeantItRels.create(:message_type => message_type_str, :message => message_str, :src_endpoint_id => @sender_endPoint.id, :dst_endpoint_id => @receiver_endPoint.id, :inbound_email_id => @inbound_email.id)
#AB      error_display("Error creating meantItRel 'sender_endPoint.id:#{sender_endPoint.id}, message_type:#{meantItRel.message_type}, receiver_endPoint.id#{receiver_endPoint.id}':#{meantItRel.errors}", meantItRel.errors) if !meantItRel.errors.empty?
      unless @meantItRel.errors.empty?
        @error_obj_arr << @meantItRel
#AA        flash[:error] = "Error creating meantItRel 'sender_endPoint.id:#{sender_endPoint.id}, message_type:#{meantItRel.message_type}, receiver_endPoint.id#{receiver_endPoint.id}':#{meantItRel.errors}"
        error_display("Error creating meantItRel 'sender_endPoint.id:#{@sender_endPoint.id}, message_type:#{@meantItRel.message_type}, receiver_endPoint.id#{receiver_endPoint.id}':#{@meantItRel.errors}", @meantItRel.errors, :error, logtag)
        return
      end # end unless @meantItRel.errors.empty?
#      @inbound_email.errors =+ meantItRel.errors
    end # end if !@sender_endPoint.nil? and !@receiver_endPoint.nil?

    respond_to do |format|
#    if !error
      format.html { redirect_to(@inbound_email, :notice => 'Inbound email was successfully created.') }
      format.xml  { render :xml => @inbound_email, :status => :created, :location => @inbound_email }
#      else
puts "InboundEmail, @inbound_email.errors:#{@inbound_email.errors.inspect}"
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @inbound_email.errors, :status => :unprocessable_entity }
#      end
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
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:error_display:#{logtag}: message:#{message}, errors:#{errors}, message_type:#{message_type}")
      flash[message_type] = message
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => errors, :status => :unprocessable_entity }
      end # respond_to
    end # end def error_display
end
