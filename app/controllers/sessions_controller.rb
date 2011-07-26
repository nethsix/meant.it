class SessionsController < ApplicationController

  before_filter :logged_in, :only => [:manage]

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
  end # end
end
