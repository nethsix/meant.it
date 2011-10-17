require 'validators'
require 'controller_helper'

class InboundEmailsController < ApplicationController
  include ControllerHelper
Rails.logger.level = Logger::DEBUG

#  before_filter :authorize, :except => [:index, :show, :create ]
  before_filter :authorize, :except => [:create ]

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
# puts "request.inspect:#{request.inspect}"
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
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, field_mapper_type:#{field_mapper_type}")
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, field_mapper:#{field_mapper.inspect}")
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
    logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, created inbound_email with id:#{@inbound_email.id}")
    sender_str = inbound_email_params[field_mapper[:from]]
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, sender_str = inbound_email_params[field_mapper[:from]]:#{inbound_email_params[field_mapper[:from]]}")
    # If not from sendgrid server url then don't use the sender_str
    # make it anonymous or use session
    if !self.request.path.match(/#{Constants::SENDGRID_PARSE_URL}/) # or !Constants::SENDGRID_SMTP_WHITELIST.include?(self.request.env['REMOTE_ADDR'])
      # Check for session id
      # CODE!!!
      # else use anonymous
      sender_str = "anonymous#{Constants::MEANT_IT_PII_SUFFIX}" if !admin?
    end # end if !self.request.path.match(/#{Constants::SENDGRID_PARSE_URL}/)
    sender_email_hash = ControllerHelper.parse_email(sender_str)
    sender_str = sender_email_hash[ControllerHelper::EMAIL_STR]
    sender_nick_str = sender_email_hash[ControllerHelper::EMAIL_NICK_STR]
    # Parse sender string to derive nick and email address
    # If sender_nick_str is email, e.g., some smtp servers provide
    # "hello_kitty@sanrio.com <hello_kitty@sanrio.com>" then we
    # don't use the nick
    sender_nick_str = nil if !sender_nick_str.nil? and !sender_nick_str.match(/.*@.*\..*/).nil?
    logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, sender_str:#{sender_str}")
    logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, sender_nick_str:#{sender_nick_str}")
    sender_email_addr = inbound_email_params[field_mapper[:to]]
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, sender_email_addr = inbound_email_params[field_mapper[:to]]:#{inbound_email_params[field_mapper[:to]]}")
    message_type_str = ControllerHelper.parse_message_type_from_email_addr(sender_email_addr, logtag)
    logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, message_type_str:#{message_type_str}")
    # Create sender EndPoint
    sender_pii_hash = ControllerHelper.get_pii_hash(sender_str)
    logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, sender_pii_hash:#{sender_pii_hash.inspect}")
    @sender_pii = Pii.find_or_create_by_pii_value_and_pii_type_and_pii_hide(sender_pii_hash[ControllerHelper::PII_VALUE_STR], sender_pii_hash[ControllerHelper::PII_TYPE], sender_pii_hash[ControllerHelper::PII_HIDE]) do |pii_obj|
      logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, created sender_pii")
    end # end Pii.find_or_create_by_pii ...
    unless @sender_pii.errors.empty?
       @error_obj_arr << @sender_pii
      error_display("Error creating sender_pii '#{sender_str}':#{@sender_pii.errors}", @sender_pii.errors, :error, logtag)
      return
    end # unless @sender_pii.errors.empty?
#20110628a    @sender_endPoint = @sender_pii.endPoint
#20110628a : Start
    sender_endPoints = @sender_pii.endPoints
    sender_endPoints_arr = sender_endPoints.select { |elem| elem.creator_endpoint_id == elem.id }
    if !sender_endPoints_arr.nil?
      @sender_endPoint = sender_endPoints_arr[0]
      if sender_endPoints_arr.size > 1
        logger.warn("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, more than one sender_endPoints with id == creator_endpoint_id, sender_endPoints_arr:#{sender_endPoints_arr.inspect}")
      end # end if sender_endPoints_arr.size > 1
    end # end if sender_endPoints_arr.nil?
#20110628a : End
    if @sender_endPoint.nil?
#20110628a      @sender_endPoint = @sender_pii.create_endPoint(:nick => sender_nick_str, :start_time => Time.now)
      @sender_endPoint = @sender_pii.endPoints.create(:nick => sender_nick_str, :start_time => Time.now)
      # Save the association
      @sender_endPoint.pii = @sender_pii
      @sender_endPoint.nick = sender_nick_str
      @sender_endPoint.creator_endpoint_id = @sender_endPoint.id
      unless @sender_endPoint.save
        @error_obj_arr << @sender_endPoint
        error_display("Error creating @sender_endPoint '#{@sender_endPoint.inspect}:#{@sender_endPoint.errors}", @sender_endPoint.errors, :error, logtag)
        return
      end # end unless @sender_endPoint.save
      @sender_pii.reload
#20110725add_auth      @sender_pii.endPoints << @sender_endPoint
#20110725add_auth      unless @sender_pii.save
#20110725add_auth        @error_obj_arr << @sender_pii
#20110725add_auth        error_display("Error saving @sender_pii'#{@sender_pii.inspect}:#{@sender_pii.errors}", @sender_pii.errors, :error, logtag)
#20110725add_auth        return
#20110725add_auth      end # end unless @sender_pii.save
      logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, acquired sender_endPoint with id:#{@sender_endPoint.id}")
    end # end if @sender_endPoint.nil?
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, @sender_endPoint.entities:#{@sender_endPoint.entities}")
#20110713    if @sender_endPoint.entities.empty?
#20110713      # Create person
#20110713      @person = ControllerHelper.find_or_create_person_by_email(sender_nick_str, sender_str, logtag)
#20110713      unless @person.errors.empty?
#20110713        @error_obj_arr << @person
#20110713        error_display("Error creating person 'name:#{sender_nick_str}, email:#{sender_str}:#{@person.errors}", @person.errors, :error, logtag)
#20110713        return
#20110713      end # end unless @person.errors.empty?
#20110713      # Create an entity having property_document with sender email
#20110713      entity_collection = Entity.where("property_document_id = ?", @person.id.to_s)
#20110713      logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, for @person.id:#{@person.id}, entity_collection.inspect:#{entity_collection.inspect}")
#20110713      if entity_collection.empty?
#20110713        @entity = Entity.create(:property_document_id => @person.id)
#20110713      else
#20110713        @entity = entity_collection[0]
#20110713      end # end if entity_collection.empty?
#20110713      unless @entity.errors.empty?
#20110713        @error_obj_arr << @entity
#20110713        error_display("Error creating entity 'property_document_id:#{@person.id}':#{@entity.errors}", @entity.errors, :error, logtag)
#20110713        return
#20110713      end # end unless @entity.errors.empty?
#20110713      # Link entity to the @sender_endPoint
#20110713      if @entity.errors.empty?
#20110713        # We cannot just do @entity.endPoints << @sender_endPoint
#20110713        # because EntityEndPointRels.verification_type must not be null
#20110713        @entityEndPointRel1 = @entity.entityEndPointRels.create(:verification_type => VerificationTypeValidator::VERIFICATION_TYPE_EMAIL)
#20110713        @entityEndPointRel1.endpoint_id = @sender_endPoint.id
#20110713        unless @entityEndPointRel1.save
#20110713          @error_obj_arr << @entityEndPointRel1
#20110713          error_display("Error creating entityEndPointRel 'entity:#{@entity.name} relate @sender_endPoint:#{@sender_endPoint.id}':#{@entityEndPointRel1.errors}", @entityEndPointRel1.errors, :error, logtag)
#20110713          return
#20110713        end # end unless @entityEndPointRel1.save
#20110713      end # end if @entity.errors.empty?
#20110713    end # end if @sender_endPoint.entities.empty?
    # Look at subject if it's not nil
    # else use body_text
    input_str = inbound_email_params[field_mapper[:subject]]
    if input_str.nil? or input_str.empty?
      input_str = inbound_email_params[field_mapper[:body_text]]
    end # end if input_str.nil? or input_str.empty?
    logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, input_str:#{input_str}")
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
    receiver_pii_hash = ControllerHelper.get_pii_hash(receiver_pii_str)
    receiver_pii_str = receiver_pii_hash[ControllerHelper::PII_VALUE_STR]
    logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, receiver_pii_hash:#{receiver_pii_hash.inspect}")
    receiver_nick_str = meantItInput_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    tag_str_arr = meantItInput_hash[ControllerHelper::MEANT_IT_INPUT_TAGS]

    # Four conditions:
    # 1. receiver_pii_str: empty, receiver_nick_str: empty
    # 2. receiver_pii_str: yes, receiver_nick_str: yes
    # 3. receiver_pii_str: yes, receiver_nick_str: empty
    # 4. receiver_pii_str: empty, receiver_nick_str: yes
    logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, receiver_pii_str:#{receiver_pii_str}, receiver_nick_str:#{receiver_nick_str}")

    # Case 1. receiver_pii_str: empty, receiver_nick_str: empty
    # Cannot identify receiver
    if (receiver_pii_str.nil? or receiver_pii_str.empty?) and (receiver_nick_str.nil? or receiver_nick_str.empty?)
      logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, case 1")
      @receiver_endPoint = EndPoint.new
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
      logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, case 2, 3")
      # Create receiver pii if it does not possess one
      @receiver_pii = Pii.find_or_create_by_pii_value_and_pii_type_and_pii_hide(receiver_pii_hash[ControllerHelper::PII_VALUE_STR], receiver_pii_hash[ControllerHelper::PII_TYPE], receiver_pii_hash[ControllerHelper::PII_HIDE]) do |pii_obj|
        logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, created receiver_pii")
      end # end Pii.find_or_create_by_pii ...
      # If @receiver_pii has an entity prefix 
      # automatically tie it to the prefix
      if (receiver_pii_match_arr = ControllerHelper.auto_entity_domain?(@receiver_pii.pii_value))
        receiver_entity = Entity.find(receiver_pii_match_arr[ControllerHelper::AUTO_ENTITY_DOMAIN_ENTITY_ID]) if !receiver_pii_match_arr.nil?
        if !receiver_entity.nil?
          entityEndPointRel_exist = receiver_entity.endPoints.collect { |ep_elem| ep_elem.pii.pii_value if !ep_elem.pii.nil? }.include?(@receiver_pii.pii_value)
          if !entityEndPointRel_exist
            # Since entity can only tie to endpoints, we use the sender endpoint
            receiver_sender_endPoint = ControllerHelper.find_or_create_sender_endPoint_and_pii(@receiver_pii.pii_value, @receiver_pii.pii_type, @receiver_pii.pii_hide)
            entityEndPointRel1 = receiver_entity.entityEndPointRels.create(:verification_type => VerificationTypeValidator::VERIFICATION_TYPE_AUTO_ENTITY_DOMAIN)
            entityEndPointRel1.endpoint_id = receiver_sender_endPoint.id
            unless entityEndPointRel1.save
              logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, entityEndPointRel1.errors.inspect:#{entityEndPointRel1.errors.inspect}")
            end # end unless entityEndPointRel1.save
            receiver_sender_endPoint.reload
          end # end if !entityEndPointRel_exist
        end # end if !receiver_entity.nil?
      end # end if (receiver_pii_match_arr = ControllerHelper.auto_entity_domain? ...
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
      logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, case 2, 4")
      @receiver_endPoint = EndPoint.find_or_create_by_nick_and_creator_endpoint_id(:nick => receiver_nick_str, :creator_endpoint_id => @sender_endPoint.id, :start_time => Time.now) do |ep_obj|
        logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, created receiver_endPoint - case 2, 4")
      end # end @receiver_endPoint ...
    end # end Cases 2 and 4 ...

    # For Case 2. receiver_pii_str: yes, receiver_nick_str: yes 
    # and they have been linked before, we check validity
    # If @receiver_pii and @receiver_endPoints exist and there were no 
    # errors creating them they must point to each other if they
    # are not pointing to nil.
p "### @receiver_pii.inspect:#{@receiver_pii.inspect}"
p "### @receiver_endPoint.inspect:#{@receiver_endPoint.inspect}"
#20110628a : Start
    # We are only interested in endPoints created by us
    # They may have different nicks/roles/empty nicks
    # Resist the urge to populate empty nicks because if
    # a user sends to just pii, i.e., without nick, then we update
    # the endPoint with empty nick.
    our_receiver_pii_endPoints = []
    our_receiver_pii_endPoints = @receiver_pii.endPoints.select { |elem| elem.creator_endpoint_id == @sender_endPoint.id } if !@receiver_pii.nil? and !@receiver_pii.endPoints.nil?
p "### our_receiver_pii_endPoints:#{our_receiver_pii_endPoints.inspect}"
#20110628a : End
    if (!@receiver_pii.nil? and !@receiver_pii.errors.any?) and (!@receiver_endPoint.nil? and !@receiver_endPoint.errors.any?)
#20110628a : Start
      # Endpoint can only have one pii so need to check that
      if !@receiver_endPoint.pii.nil? and (@receiver_endPoint.pii.pii_value != @receiver_pii.pii_value)
        @error_obj_arr << @receiver_endPoint
        error_display("receiver_endPoint '#{@receiver_endPoint.nick}' already has pii_value '#{@receiver_endPoint.pii.pii_value}' so it cannot accept new value '#{receiver_pii_str}'",  @receiver_endPoint.errors, :error, logtag) 
        return
      end # end if @receiver_endPoint.pii.pii_value ...
      # Since we permite a user to create mulitple nicks/roles
      # tied to a pii, e.g., manager (xxx@yyy.com), lover (xxx@yyy.com)
      # we just need to check that the new nick endpoint does not exist,
      # before adding them.  If it exists use it as exsiting endpoints.
      # This also handles if initially receiver is just nick (endpoint created)
      # later the nick is accompanied with pii.
      if our_receiver_pii_endPoints.index(@receiver_endPoint).nil?
        @receiver_endPoint.pii = @receiver_pii
        unless @receiver_endPoint.save
          @error_obj_arr << @receiver_endPoint
          error_display("Error saving receiver_pii '#{@receiver_pii.inspect}' to receiver_endPoint '{@receiver_endPoint.inspect}'",  @receiver_endPoint.errors, :error, logtag) 
          return
        end # end unless @receiver_endPoint.save
        @receiver_pii.reload
#20110725add_auth        @receiver_pii.endPoints << @receiver_endPoint
#20110725add_auth        unless @receiver_pii.save
#20110725add_auth          @error_obj_arr << @receiver_pii
#20110725add_auth          error_display("Error saving @receiver_pii'#{@receiver_pii.inspect}:#{@receiver_pii.errors}", @receiver_pii.errors, :error, logtag)
#20110725add_auth          return
#20110725add_auth        end # end unless @receiver_pii.save
      end # end if our_receiver_pii_endPoints.index(@receiver_endPoint).nil?
#20110628a : End
#20110628a : End
#20110628a       # We have an endpoint (nick) and pii
#20110628a       # Each nick/pii can either point to each other (OK)
#20110628a       # another entity (ERROR), or nothing.
#20110628a       # There are 9 combos:
#20110628a       # The only valid ones are:
#20110628a       # Case #A: nick/pii points to nil
#20110628a p "AAAAAAAAAAA @receiver_pii:#{@receiver_pii.inspect}"
#20110628a p "AAAAAAAAAAA @receiver_endPoint:#{@receiver_endPoint.inspect}"
#20110628a p "AAAAAAAAAAA @receiver_endPoint.pii:#{@receiver_endPoint.pii.inspect}"
#20110628a      if @receiver_pii.endPoint.nil? and @receiver_endPoint.pii.nil?
#20110628aAA      if receiver_pii_endPoints.empty? and @receiver_endPoint.pii.nil?
#20110628a p "\nAAAAAAAAAAA NORMAL!!!\n"
#20110628a        @receiver_pii.endPoint = @receiver_endPoint
#20110628a        @receiver_pii.save
#20110628aAA        @receiver_endPoint.pii = @receiver_pii
#20110628aAA        @receiver_endPoint.save
#20110628a : Start
#20110628a      # Case #Aa: receiver_pii points to some empty nick_name
#20110628a      elsif !receiver_pii_endPoints.empty? and @receiver_endPoint.pii.nil?
#20110628a#20110628a : End
#20110628a      # Case #B: nick points to nothing, pii points to something but has no nick
#20110628a      # and has the same creator_endpoint_id
#20110628a      elsif (!@receiver_pii.endPoint.nil? and @receiver_pii.endPoint.nick.nil?) and @receiver_endPoint.pii.nil?
#20110628ap "\n!!!!!! YOU CAN'T BE SERIOUS!!!!!\n"
#20110628a        @receiver_pii.endPoint.nick = receiver_nick_str
#20110628a        @receiver_pii.save
#20110628a        @receiver_endPoint.destroy
#20110628a        @receiver_endPoint = @receiver_pii.endPoint
#20110628a      # Case #C: nick points to this pii and vice versa
#20110628a      elsif (!@receiver_pii.endPoint.nil? and !@receiver_endPoint.pii.nil? and @receiver_pii.endPoint == @receiver_endPoint and @receiver_endPoint.pii == @receiver_pii)
#20110628ap "\nHUH!!!!?!??! NORMAL!!!\n"
#20110628a        # OK
#20110628a      elsif (!@receiver_pii.endPoint.nil? and !@receiver_endPoint.pii.nil? and @receiver_pii.endPoint != @receiver_endPoint and @receiver_endPoint.pii != @receiver_pii)
#20110628a        @error_obj_arr << @receiver_endPoint
#20110628a        error_display("receiver_endPoint '#{@receiver_endPoint.nick}' already has pii_value '#{@receiver_endPoint.pii.pii_value}' so it cannot accept new value '#{receiver_pii_str}'",  @receiver_endPoint.errors, :error, logtag) 
#20110628a        return
#20110628a      else
#20110628a        # Should not happen unless corrupted
#20110628a        @error_obj_arr << @receiver_endPoint
#20110628a        error_display("receiver_endPoint 'nick:#{@receiver_endPoint.nick}, pii:#{@receiver_endPoint.pii.inspect}' conflicts with receiver_pii 'pii:#{@receiver_pii.pii_value}, endPoint:#{@receiver_pii.endPoint.inspect}",  @receiver_endPoint.errors, :error, logtag) 
#20110628a        return
#20110628a      end # end if @receiver_pii.endPoint.nil? and @receiver_endPoint.pii.nil?

#20110627a      if !@receiver_pii.endPoint.nil? and !@receiver_endPoint.pii.nil?
#20110627a        unless (@receiver_pii.endPoint == @receiver_endPoint and @receiver_endPoint.pii = @receiver_pii)
#20110627a          @error_obj_arr << @receiver_endPoint
#20110627a          error_display("receiver_endPoint '#{@receiver_endPoint.nick}' already has pii_value '#{@receiver_endPoint.pii.pii_value}' so it cannot accept new value '#{receiver_pii_str}'",  @receiver_endPoint.errors, :error, logtag) 
#20110627a          return
#20110627a        end # end unless @receiver_pii.endPoint ==  ...
#20110627a      else
#20110627a        if @receiver_pii.endPoint.nil?
#20110627a          @receiver_pii.endPoint = @receiver_endPoint
#20110627a        end # end if @receiver_pii.endPoint.nil?
#20110627a        if @receiver_endPoint.pii.nil?
#20110627a          @receiver_endPoint.pii = @receiver_pii
#20110627a        end # end if @receiver_endPoint.pii.nil?
#20110627a      end # end if !@receiver_pii.endPoint.nil? and !@receiver_endPoint.pii.nil?
    end # end if (!@receiver_pii.nil? and !@receiver_pii.errors.any?)  ...

    # For Case 3. receiver_pii_str: yes, receiver_nick_str: empty
    # we create endPoint and tie receiver_pii to it
    if ((!receiver_pii_str.nil? and !receiver_pii_str.empty?) and (receiver_nick_str.nil? or receiver_nick_str.empty?))
#20110628a : Start
      # Check if we already have endPoint with no nick.  If so use it.
      receiver_endPoint_no_nick_arr = our_receiver_pii_endPoints.select { |elem| elem.nick.nil? }
      @receiver_endPoint = receiver_endPoint_no_nick_arr[0] if !receiver_endPoint_no_nick_arr.nil? and receiver_endPoint_no_nick_arr.size > 0
      if receiver_endPoint_no_nick_arr.size > 1
        logger.warn("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, more than one receiver_endPoints with nick = nil, receiver_endPoint_no_nick_arr:#{receiver_endPoint_no_nick_arr.inspect}")
      end # end if receiver_endPoint_no_nick_arr.size > 1
#20110628a : End
#20110628a      @receiver_endPoint = EndPoint.create(:creator_endpoint_id => @sender_endPoint.id, :start_time => Time.now)
      @receiver_endPoint = EndPoint.create(:creator_endpoint_id => @sender_endPoint.id, :start_time => Time.now) if @receiver_endPoint.nil?
      logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, created receiver_endPoint - case 3")
      @receiver_endPoint.pii = @receiver_pii
      unless @receiver_endPoint.save
        @error_obj_arr << @receiver_endPoint
        error_display("Error saving receiver_pii '#{@receiver_pii.inspect}' to receiver_endPoint '{@receiver_endPoint.inspect}'",  @receiver_endPoint.errors, :error, logtag) 
        return
      end # end unless @receiver_endPoint.save
      @receiver_pii.reload
#20110725add_auth      @receiver_pii.endPoints << @receiver_endPoint
#20110725add_auth      unless @receiver_pii.save
#20110725add_auth        @error_obj_arr << @receiver_pii
#20110725add_auth        error_display("Error saving @receiver_pii'#{@receiver_pii.inspect}:#{@receiver_pii.errors}", @receiver_pii.errors, :error, logtag)
#20110725add_auth        return
#20110725add_auth      end # end unless @receiver_pii.save
    end # end if ((!receiver_pii_str.nil? and !receiver_pii_str.empty?)  ...
    
    # For Case 4. receiver_pii_str: empty, receiver_nick_str: yes
    # We already have endPoint. Tags, meant_it_rels are tied to endPoints.

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
#20110627    else
#20110627      # Create receiver pii if it does not possess one
#20110627      @receiver_pii = Pii.find_or_create_by_pii_value_and_pii_type(receiver_pii_str, PiiTypeValidator::PII_TYPE_EMAIL) do |pii_obj|
#20110627        logger.info("#{File.basename(__FILE__)}:#{self.class}:create:#{logtag}, created receiver_pii")
#20110627      end # end Pii.find_or_create_by_pii ...
#20110627      unless @receiver_pii.errors.empty? or receiver_pii_str.nil? or receiver_pii_str.empty?
#20110627        @error_obj_arr << @receiver_pii
#20110627        error_display("Error creating receiver_pii '#{receiver_pii_str}'",  @receiver_pii.errors, :error, logtag) 
#20110627        return
#20110627      end # end unless @receiver_pii.errors.empty?
#20110627      @receiver_endPoint.pii = @receiver_pii
#20110627      unless @receiver_endPoint.save
#20110627        @error_obj_arr << @receiver_endPoint
#20110627        error_display("Error saving receiver_pii '#{@receiver_pii.inspect}' to receiver_endPoint '{@receiver_endPoint.inspect}'",  @receiver_endPoint.errors, :error, logtag) 
#20110627        return
#20110627      end # end unless @receiver_endPoint.save
#20110627    end # end if @receiver_endPoint.pii


    unless @receiver_endPoint.errors.empty?
      @error_obj_arr << @receiver_endPoint
      error_display("Error creating @receiver_endPoint '#{@receiver_endPoint.inspect}':#{@receiver_endPoint.errors}", @receiver_endPoint.errors, :error, logtag)
      return
    end # end unless @receiver_endPoint.errors.empty?
    if !@receiver_endPoint.nil?
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, tag_str_arr.inspect:#{tag_str_arr.inspect}")
      # Add tags that are not yet attached to the @receiver_endPoint
      existing_tag_str_arr = @receiver_endPoint.tags.collect { |tag_elem| tag_elem.name }
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, existing_tag_str_arr:#{existing_tag_str_arr}")
#20110628b      yet_2b_associated_tag_str_arr = (existing_tag_str_arr - tag_str_arr) + (tag_str_arr - existing_tag_str_arr)
      yet_2b_associated_tag_str_arr = tag_str_arr - existing_tag_str_arr
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, yet_2b_associated_tag_str_arr:#{yet_2b_associated_tag_str_arr}")
      yet_2b_associated_tag_str_arr.each { |tag_str_elem|
        norm_tag_str_elem = tag_str_elem.downcase
        @new_tag = Tag.find_or_create_by_name(norm_tag_str_elem) do |tag_obj|
          logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, created tag:#{norm_tag_str_elem}")
        end # end Tag.find_or_create_by ...
        unless @new_tag.errors.empty?
          @error_obj_arr << @new_tag
          error_display("Error creating new_tag '#{norm_tag_str_elem}':#{@new_tag.errors}", @new_tag.errors, :error, logtag)
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
        error_display("Error creating meantItRel 'sender_endPoint.id:#{@sender_endPoint.id}, message_type:#{@meantItRel.message_type}, @receiver_endPoint.id#{@receiver_endPoint.id}':#{@meantItRel.errors}", @meantItRel.errors, :error, logtag)
        return
      end # end unless @meantItRel.errors.empty?
      if @meantItRel.errors.empty?
        if message_type_str == MeantItMessageTypeValidator::MEANT_IT_MESSAGE_OTHER
          # Call mood reasoner
          # CODE!!!!! Implement this in ControllerHelper
        else
          logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}: creating mood using message_type_str:#{message_type_str}")
          @new_mood_tag = Tag.find_or_create_by_name_and_desc(message_type_str, MeantItMoodTagRel::MOOD_TAG_TYPE) do |tag_obj|
           logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, created mood_tag:#{message_type_str}")
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
    # Things that require 200 otherwise they'll keep resending, e.g.
    # sendgrid
    if self.request.path.match(/#{Constants::SENDGRID_PARSE_URL}/)
      render :xml => @inbound_email, :status => 200
      return
    end # end if self.request.path.match(/#{Constants::SENDGRID_PARSE_URL}/)
    # This is from meant_it find/send main page
    if self.request.path.match(/send_inbound_emails/)
      if !@sender_pii.nil? and !@receiver_pii.nil?
        logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}: send_inbound_emails: @sender_pii.inspect:#{@sender_pii.inspect}, @receiver_pii.inspect:#{@receiver_pii.inspect}, message_type_str:#{message_type_str}")
        # Check for space
        sender_pii_pii_value_str = @sender_pii.pii_value
        receiver_pii_pii_value_str = @receiver_pii.pii_value
        if !@sender_pii.pii_value.scan(' ').empty?
          sender_pii_pii_value_str = "'#{@sender_pii.pii_value}'"
        end # end if @sender_pii.pii_value.scan(' ').empty?
        if !@receiver_pii.pii_value.scan(' ').empty?
          receiver_pii_pii_value_str = "'#{@receiver_pii.pii_value}'"
        end # end if @receiver_pii.pii_value.scan(' ').empty?
        find_any_input_str = "#{sender_pii_pii_value_str} #{message_type_str} #{receiver_pii_pii_value_str}"
        logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}: @sender_pii.inspect:#{@sender_pii.inspect}, @receiver_pii.inspect:#{@receiver_pii.inspect}, message_type_str:#{message_type_str}, find_any_input_str:#{find_any_input_str}")
#20111017        render "/find_any/show_pii_pii_with_message_type.html.erb", :layout => "find_any", :locals => { :notice => nil, :sender_pii => @sender_pii, :receiver_pii => @receiver_pii, :message_type => message_type_str, :find_any_input => find_any_input_str }
        render "/home/index", :layout => "find_any", :locals => { :notice => nil }
      elsif !@sender_pii.nil? and @receiver_pii.nil? and !@receiver_endPoint.nil?
        sender_pii_pii_value_str = @sender_pii.pii_value
        if !@sender_pii.pii_value.scan(' ').empty?
          sender_pii_pii_value_str = "'#{@sender_pii.pii_value}'"
        end # end if @sender_pii.pii_value.scan(' ').empty?
        find_any_input_str = "#{sender_pii_pii_value_str} #{message_type_str} #{@receiver_endPoint.nick}"
        logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}: @sender_pii.inspect:#{@sender_pii.inspect}, @receiver_endPoint.inspect#{@receiver_endPoint.inspect}, message_type_str:#{message_type_str}, find_any_input_str:#{find_any_input_str}")
#20111017        render "/find_any/show_endpoints_pii_with_message_type", :layout => "find_any", :locals => { :notice => nil, :endPoints => [@receiver_endPoint], :pii => @sender_pii, :message_type => message_type_str, :find_any_input => find_any_input_str }
        render "/home/index", :layout => "find_any", :locals => { :notice => nil }
      end # end if !@sender_pii.nil? ...
      return
    end # end if self.request.path.match(/send_inbound_emails/)
    respond_to do |format|
      format.html { redirect_to(@inbound_email, :notice => 'Inbound email was successfully created.') }
      format.xml  { render :xml => @inbound_email, :status => :created, :location => @inbound_email }
#puts "InboundEmail, @inbound_email.errors:#{@inbound_email.errors.inspect}"
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
        if self.request.path.match(/#{Constants::SENDGRID_PARSE_URL}/)
          logger.warn("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:error_display:#{logtag}: inbound email with params:#{message}, generated errors:#{errors.inspect}")
          # Problem with inbound_email saving, this is the fault
          # automated sender.  Only automated sender uses inbound_emails_200
          # Record this error
          @inbound_email_logs = InboundEmailLog.create(:params_txt => params.inspect.to_s, :error_msgs => message, :error_objs => @inbound_email.errors.inspect.to_s)
        else
          # We don't worry cause user will see error message
        end # end if self.request.path.match(/#{Constants::SENDGRID_PARSE_URL}/)
      else
        logger.warn("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:error_display:#{logtag}: inbound email saved but controller processing resulted in message:#{message}, and errors:#{errors.inspect}")
        @inbound_email.error_msgs = message.to_s
        @inbound_email.error_objs = errors.inspect.to_s
        @inbound_email.save
      end # end if @inbound_email.errors.any?
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:error_display:#{logtag}: message:#{message}, errors:#{errors}, message_type:#{message_type}")
      flash[message_type] = message
      # Things that require 200 otherwise they'll keep resending, e.g.
      # sendgrid
      if self.request.path.match(/#{Constants::SENDGRID_PARSE_URL}/)
        render :xml => errors, :status => 200
        return
      end # end if self.request.path.match(/#{Constants::SENDGRID_PARSE_URL}/)
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => errors, :status => :unprocessable_entity }
      end # respond_to
    end # end def error_display
end
