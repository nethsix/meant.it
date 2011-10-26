require 'controller_helper'

class MeantItConfirmationsController < Devise::ConfirmationsController
  prepend_view_path "app/views/devise"

#20111023SOLN#2  before_filter :redirect_not_logged_in, :only => [:show]

  def show
    logtag = ControllerHelper.gen_logtag
    confirmation_token = params[:confirmation_token]
    user = User.find_by_confirmation_token(confirmation_token)
    self.resource = resource_class.confirm_by_token(confirmation_token)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:show:#{logtag}, params.inspect:#{params.inspect}")
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:show:#{logtag}, env['rack.session.options'].inspect:#{env['rack.session.options'].inspect}")

    if resource.errors.empty?
      # Find the endpoint/pii, i.e., endpoint whose creator_endpoint_id
      # is the same as endpoint_id
      pii = Pii.find_by_pii_value_and_pii_type(user.email, PiiTypeValidator::PII_TYPE_EMAIL)
      endPoint = ControllerHelper.find_or_create_sender_endPoint_and_pii(user.email, PiiTypeValidator::PII_TYPE_EMAIL)
      # If already logged in then confirm email to logged in entity
      if !current_entity.nil?
        entityEndPointRel1 = current_entity.entityEndPointRels.create(:verification_type => VerificationTypeValidator::VERIFICATION_TYPE_EMAIL)
        entityEndPointRel1.endpoint_id = endPoint.id
        unless entityEndPointRel1.save
          logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:show:#{logtag}, entityEndPointRel1.errors.inspect:#{entityEndPointRel1.errors.inspect}")
        end # end unless entityEndPointRel1.save
        flash[:notice] = "Claimed email '#{user.email}'"
      else
        session[Constants::SESSION_CONFIRM_EMAIL_ENDPOINT_ID]= endPoint.id
        logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:show:#{logtag}, setting session[Constants::SESSION_CONFIRM_EMAIL_ENDPOINT_ID], session.inspect:#{session.inspect}")
        redirect_to "/log_in"
#20111023SOLN#2        logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:show:#{logtag}, this should not happen since before_filter ensures that there is login before we can reach this part of code, session.inspect:#{session.inspect}")
#20111023SOLN#2        flash[:error] = "Can't confirm email association without login"
#20111023SOLN#2        redirect_to url_for("/")
        return
      end # end if !current_entity.nil?
    end # end if resource.errors.empty?
    render "home/index", :layout => "find_any"
  end # end def show
end # end class MeantItConfirmationsController
