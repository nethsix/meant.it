class InboundEmailsController < ApplicationController
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
puts "InboundEmail, create:#{params[:inbound_email].inspect}"
    @inbound_email = InboundEmail.new(
      :headers => params["headers"],
      :body_text => params["text"],
      :body_html => params["html"],
      :from => params["from"],
      :to => params["to"],
      :subject => params["from"],
      :cc => params["cc"],
      :dkim => params["dkim"],
      :spf => params["spf"],
      :envelope => params["envelope"],
      :charsets => params["charsets"],
      :spam_score => params["spam_score"],
      :spam_report => params["spam_report"],
      :attachment_count => params["attachments"]
    )

    error = false
    error = true if !@inbound_email.save
    sender_str = params["from"]
    message_type_str = params["to"]
    message_type_str_match_arr = nil
    message_type_str_match_arr = message_type_str.match /(.*)@.*/ if !message_type_str.nil?
    if message_type_str_match_arr.nil?
      message_type_str = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_THANK
    else
      message_type_str = message_type_str_match_arr[1]
    end # end if message_type_str.nil? or message_type_str.empty?
    # Parse sender string to derive nick and email address
    sender_str_match_arr = sender_str.match(/(.*)<(.*)>/)
    sender_nick_str = sender_str_match_arr[1].strip if !sender_str_match_arr.nil?
    sender_str = sender_str_match_arr[2] if !sender_str_match_arr.nil?
    sender_nick_str ||= sender_str
    # Create sender EndPoint
    sender_pii = Pii.find_or_create_by_pii_value_and_pii_type(sender_str, PiiTypeValidator::PII_TYPE_EMAIL)
    sender_endPoint = sender_pii.endPoint
    @inbound_email.errors += sender_endPoint.errors
    if sender_endPoint.nil?
      sender_endPoint = sender_pii.create_endPoint(:nick => sender_nick_str, :start_time => Time.now)
      # Save the association
      sender_endPoint.pii = sender_pii
      sender_endPoint.nick = sender_nick_str
      sender_endPoint.creator_endpoint_id = sender_endPoint.id
      sender_endPoint.save
      @inbound_email.errors =+ sender_endPoint.errors
    end # end if sender_endPoint.nil?
    # Look at subject if it's not nil
    # else use body_text
    # Decide what to do on nick, pii, message, tags...
    # Case:
    # nick (yes) :xxx (no) ;yyy (*) tags (yes): sender (global id-able source)
    input_str = params["subject"]
    input_str ||= params["text"]
    # Determine nick, :xxx, :yyy, tags
    input_str_arr = input_str.split
    receiver_nick_str = input_str_arr.shift
    tag_str_arr = Array.new
    receiver_pii_str = nil
    message_str = nil
    input_str_arr.each { |input_str_arr_elem|
      if input_str_arr_elem[0,1] == ":"
        receiver_pii_str = input_str_arr_elem
      elsif input_str_arr_elem[0,1] == ";"
        message_str = input_str_arr_elem
      else
        tag_str_arr.push(input_str_arr_elem)
      end # end if input_str_arr_elem ...
    } // end input_str_arr.each ...
    tag_str_arr = nil if tag_str_arr.empty? 
    # From nick, receiver_pii, message, tag, create the necesary
    # database objects
    receiver_endPoint = EndPoint.find_or_create_by_nick_and_creator_endpoint_id(:nick => receiver_nick_str, :creator_endpoint_id => sender_endPoint.id, :start_time => Time.now)
    @inbound_email.errors =+ receiver_endPoint.errors
    if !receiver_endPoint.nil?
      # Add tags that are not yet attached to the receiver_endPoint
      existing_tag_str_arr = receiver_endPoint.tags.collect { |tag_elem| tag_elem.name }
      yet_2b_associated_tag_str_arr = (existing_tag_str_arr - tag_str_arr) + (tag_str_arr - existing_tag_str_arr)
      yet_2b_associated_tag_str_arr.each { |tag_str_elem|
        new_tag = Tag.find_or_create_by_name(tag_str_elem)
        receiver_endPoint.tags << new_tag
      } # end tag_str_arr.each ...
    end # end if !receiver_endPoint.nil?
    # Create meant_it rel
    if !sender_endPoint.nil? and !receiver_endPoint.nil?
      meantItRel = sender_endPoint.srcMeantItRels.create(:message_type => "thank", :src_endpoint_id => sender_endPoint.id, :dst_endpoint_id => receiver_endPoint.id)
      @inbound_email.errors =+ meantItRel.errors
    end # end if !sender_endPoint.nil? and !receiver_endPoint.nil?

    respond_to do |format|
    if !error
        format.html { redirect_to(@inbound_email, :notice => 'Inbound email was successfully created.') }
        format.xml  { render :xml => @inbound_email, :status => :created, :location => @inbound_email }
      else
puts "InboundEmail, @inbound_email.errors:#{@inbound_email.errors.inspect}"
        format.html { render :action => "new" }
        format.xml  { render :xml => @inbound_email.errors, :status => :unprocessable_entity }
      end
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
end
