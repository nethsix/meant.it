require 'constants'
class SessionsController < ApplicationController

  before_filter :logged_in, :only => [:manage, :send_liker_emails]

  def new
  end

  def manage
    logtag = ControllerHelper.gen_logtag
    @claim = params[Constants::CLAIM_INPUT]
    if @claim.nil?
      email_hash = ControllerHelper.parse_email(current_entity.login_name)
      if !email_hash[ControllerHelper::EMAIL_STR].nil?
        user = User.find_by_email(current_entity.login_name)
        if user.nil? or (!user.nil? and user.confirmed_at.nil?)
          @claim = current_entity.login_name
        end # end if user.nil? or (!user.nil? and user.confirmed_at.nil?)
      end # end if !email_hash[ControllerHelper::EMAIL_STR].nil?
    end # end if @claim.nil?
    respond_to do |format|
      format.html # render
    end
  end # end def manage

  def create  
    logtag = ControllerHelper.gen_logtag
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, session.inspect:#{session.inspect}")
    login_name = params[:session][:login_name]
    pword = params[:session][:password]
    entity = Entity.authenticate(login_name, pword)  
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, login_name:#{login_name}, entity.inspect:#{entity.inspect}")
    new_entity = nil
    if entity
      notice_str = "Logged in!"
      session[Constants::SESSION_ENTITY_ID] = entity.id
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, session.inspect:#{session.inspect}")
      # Check if there's outstanding confirmed pii that we need to link
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, session[Constants::SESSION_CONFIRM_EMAIL_ENDPOINT_ID]:#{session[Constants::SESSION_CONFIRM_EMAIL_ENDPOINT_ID]}")
      if !session[Constants::SESSION_CONFIRM_EMAIL_ENDPOINT_ID].nil?
        confirmed_email_endpoint_id = session[Constants::SESSION_CONFIRM_EMAIL_ENDPOINT_ID]
        session[Constants::SESSION_CONFIRM_EMAIL_ENDPOINT_ID] = nil
        entityEndPointRel1 = entity.entityEndPointRels.create(:verification_type => VerificationTypeValidator::VERIFICATION_TYPE_EMAIL)
        entityEndPointRel1.endpoint_id = confirmed_email_endpoint_id
        unless entityEndPointRel1.save
          logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, entityEndPointRel1.errors.inspect:#{entityEndPointRel1.errors.inspect}")
        end # end unless entityEndPointRel1.save
        confirmed_email_endpoint = EndPoint.find(confirmed_email_endpoint_id)
        notice_str = "Claimed email '#{confirmed_email_endpoint.pii.pii_value}'"
      end # end if session[Constants::SESSION_CONFIRM_EMAIL_ENDPOINT_ID]
      redirect_to root_url, :notice => notice_str
    elsif entity == false
      flash[:alert] = "Invalid email or password"  
      redirect_to root_url, :alert => "Invalid username/password!"
    else
      # Attempt to create id but make user go through captcha
      render "/home/index.html.erb", :layout => "find_any", :locals => { :notice => "Please solve re-captcha", :show_new_user => login_name, :show_pword => pword }
    end
  end # end def create

  def verify_captcha
    if verify_recaptcha
      new_entity = ControllerHelper.create_entity(params[:session][:login_name], params[:session][:password])
      session[Constants::SESSION_ENTITY_ID] = new_entity.id
      redirect_to root_url, :notice => "Welcome '#{new_entity.login_name}'!"
    else
      redirect_to root_url, :alert => "Re-captcha failed. User '#{params[:session][:login_name]}' not created!"
    end # end if verify_recaptcha
  end # end def verify_captcha

  def destroy  
    session[Constants::SESSION_ENTITY_ID] = nil  
    redirect_to root_url, :notice => "Logged out!"  
  end 

  def resend_confirmation
    logtag = ControllerHelper.gen_logtag
    email = params[Constants::EMAIL_VALUE_INPUT]
    user = User.find_by_email(email)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:resend_confirmation:#{logtag}, email:#{email}, user.inspect:#{user.inspect}")
    if user.nil?
      new_user = User.create(:email => email, :password => current_entity.password_hash)
    elsif
      user.resend_confirmation_token
    end # end if user.nil?
    redirect_to "/", :notice => "Confirmation email sent to '#{email}'"
  end

  # Send email to likers
  def send_liker_emails
    logtag = ControllerHelper.gen_logtag
    email_count = 0
    pii_value = params[Constants::PII_VALUE_INPUT]
    # Get all unique senders
    if !pii_value.nil? and !pii_value.empty?
      pii = Pii.find_by_pii_value(pii_value)
      if !pii.pii_property_set.nil? and pii.pii_property_set.status == LikerStatusTypeValidator::LIKER_STATUS_READY
#DEBUG      if true
        mirs = ControllerHelper.get_likers_by_email_bill_entry_id(pii_value)
        if !mirs.nil? and !mirs.empty?
          # Create email bill for entity
          entity_no_match_arr = pii_value.match(/(\d+)#{Constants::ENTITY_DOMAIN_MARKER}/)
          entity_no = entity_no_match_arr[1] if !entity_no_match_arr.nil?
          logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, entity_no:#{entity_no}")
          entity = Entity.find(entity_no)
          if entity.nil?
            logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, unable to bill since no entity found from pii_value:#{pii_value}")
            flash[:error] = "Unable to bill since no entity found from pii_value:#{pii_value}"
#          raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, unable to bill since no entity found from pii_value:#{pii_value}"
          elsif entity != current_entity
            logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, Not authorized to send contract emails")
            flash[:error] = "Not authorized to send contract emails"
          end # end if entity.nil?
          pps = pii.pii_property_set
          # Create email bill entry for each mir 
          if entity.email_bill.nil?
            entity.email_bill = EmailBill.create 
          end # end if email_bill.nil?
          email_bill = entity.email_bill
          # Link every bill entry to entity email bill and pii_property_set
          email_bill.email_bill_entries.create(:pii_property_set_id => pps.id)
          mirs.each { |mir_elem|
            logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, mir_elem.inspect:#{mir_elem.inspect}")
            # Send email
            # CODE: We should actually keep all the likers that we contacted
            # since the algorithm to look for them may change and if they do
            # then the likers we contacted using the old algo could be different
            # from those using the new algo
            if !mir_elem.src_endpoint_id.nil?
              src_endpoint = EndPoint.find(mir_elem.src_endpoint_id)
              liker_pii = src_endpoint.pii
              liker_email = liker_pii.pii_value
              if !liker_email.nil? and !liker_email.empty?
                logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, send email contract to liker_email:#{liker_email}")
                UserMailer.contract_mail(pii_value, liker_email, src_endpoint).deliver if liker_email.match(/aimless/)
                email_count += 1
              else
                logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, mir_elem's src_endpoint does not have pii.pii_value, liker_person.inspect:#{liker_person.inspect}")
              end # end if liker_email.nil? or liker_email.empty?
            end # end if !mir_elem.src_endpoint_id.nil?
          } # end mirs.each { |mir_elem|
          # Check threshold_type
          # If onetime, then set status to LIKER_STATUS_BILLED
          if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
            pps.status = LikerStatusTypeValidator::LIKER_STATUS_BILLED
            unless pps.save
              logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, failed to change pii_value:#{pii_value} pps status to #{LikerStatusTypeValidator::LIKER_STATUS_BILLED}")
              raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, failed to change pii_value:#{pii_value} pps status to #{LikerStatusTypeValidator::LIKER_STATUS_BILLED}"
            end # end unless pps.save
          end # end if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
        else
          logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, send_liker_emails cannot be triggered if threshold is not reached, but it seems to be triggered yet there are no mirs!!!")
          flash[:error] = "No email sent because no likers found!!"
        end # end if !mirs.nil? and !mirs.empty?
      else
        logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, Threshold not reached so contract emails cannot be sent")
        flash[:error] = "Threshold not reached so contract emails cannot be sent!!"
      end # end if !pii.pii_property_set.nil? and pii.pii_property_set != ...
    end # end if !pii_value.nil? and !pii_value.empty?
    respond_to do |format|
      format.html { redirect_to "/manage", :layout => true, :notice => "#{email_count} emails sent" }
    end
  end # end def send_liker_emails
end
