require 'constants'
require 'errors'
class SessionsController < ApplicationController

  before_filter :logged_in, :only => [:manage, :bill, :send_liker_emails]

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
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, params.inspect:#{params.inspect}")
    login_name = params[:session][:login_name]
    pword = params[:session][:password]
    entity = Entity.authenticate(login_name, pword)  
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, login_name:#{login_name}, entity.inspect:#{entity.inspect}")
    new_entity = nil
    if entity
      notice_str = Constants::LOGGED_IN_NOTICE
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
    redirect_to root_url, :notice => Constants::LOGGED_OUT_NOTICE
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
    bill_entry_id = params[Constants::BILL_ENTRY_ID_VALUE_INPUT]
    if !bill_entry_id.nil? and !bill_entry_id.empty?
      bill_entry = EmailBillEntry.find(bill_entry_id)
      if !bill_entry.ready_date.nil? and !bill_entry.meant_it_rels.nil? and !bill_entry.meant_it_rels.empty?
        if !bill_entry.billed_date.nil?
          logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, bill_id:#{bill_entry_id} already billed")
          flash[:error] = "Bill_id:#{bill_entry_id} already billed!!"
        else
          # pii_value of likee
          pii_value = bill_entry.pii_property_set.pii.pii_value
          # Get entity
          entity = bill_entry.email_bill.entity
          if current_entity != entity
            logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, Not authorized to send contract emails")
            flash[:error] = "Not authorized to send contract emails"
          else
            # Set billing time first since we use to check
            # that billing is done
            billed_date_done = true
            bill_entry.billed_date = Time.now
            unless bill_entry.save
              billed_date_done = false
              logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, billing time not saved")
              flash[:error] = "Billing time not saved."
            end # end unless bill_entry.save
            if billed_date_done
              bill_entry.meant_it_rels.each { |mir_elem|
                logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, mir_elem.inspect:#{mir_elem.inspect}")
                ep_elem = mir_elem.src_endpoint
                # Send email
                if !ep_elem.pii.nil?
                  liker_pii = ep_elem.pii
                  liker_email = liker_pii.pii_value
                  if !liker_email.nil? and !liker_email.empty?
                    logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, send email contract to liker_email:#{liker_email}")
#DEBUG                    UserMailer.contract_mail(pii_value, liker_email, ep_elem).deliver if liker_email.match(/aimless/)
#20111106                    UserMailer.contract_mail(pii_value, liker_email, ep_elem).deliver
                    begin
                      UserMailer.contract_mail(pii_value, mir_elem).deliver
                      email_count += 1
                    rescue Exception => e
                      logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails, contract_mail delivery error, e.inspect:#{e.inspect}")
                      logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails, contract_mail delivery error trace, e.backtrace:#{e.backtrace.join("\n")}")
#20111204 We just log the error but continue to send other mails
#20111204 Later the user can see how many emails failed, etc.
#20111204                      if e.instance_of?(PaymentException)
#20111204                        @mir = mir_elem
#20111204                        @error = e
#20111204                        render "/bills/error", :layout => "payment"
#20111204                      else
#20111204                        # NOTE: For now we also show these errors so that
#20111204                        # users can maybe report error to us
#20111204                        @mir = mir_elem
#20111204                        @error = e
#20111204                        render "/bills/error", :layout => "payment"
#20111204                      end # end if e.instance_of?(PaymentException)
                    end # end catch mail errors
                  else
                    logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, ep_elem's does not have pii.pii_value, liker_person.inspect:#{liker_person.inspect}")
                  end # end if liker_email.nil? or liker_email.empty?
                end # end if !mir_elem.src_endpoint_id.nil?
              } # end bill_entry.meant_it_rels.each  ...
            end # end if billed_date_done
          end # end if current_entity != entity
        end # end if !bill_entry.billed_date.nil?
      else
        logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send_liker_emails:#{logtag}, no contract emails sent")
        flash[:error] = "No contract emails sent!!"
      end # end if !pii.pii_property_set.nil? and pii.pii_property_set != ...
    end # end if !bill_entry_id.nil? and !bill_entry_id.empty?
    respond_to do |format|
      format.html { redirect_to "/manage", :layout => true, :notice => "#{email_count} emails sent" }
    end
  end # end def send_liker_emails
end
