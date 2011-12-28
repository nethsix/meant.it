class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_entity
  helper_method :logged_in
  helper_method :redirect_not_logged_in
  helper_method :admin?
  helper_method :no_profile?
    
  protected
  def no_profile?
    if current_entity.nil?
      flash[:error] = "Unauthorized access"
      redirect_to url_for("/")
      false
    else
      if !current_entity.property_document_id.nil?
        flash[:error] = "Unauthorized access: profile already exists"
        redirect_to url_for("/")
        false
      end # end if !current_entity.property_document_id.nil?
    end # end if current_entity
  end

  def admin?
    is_admin = false
    is_admin = true if !current_entity.nil? and current_entity.login_name = "nethsix@gmail.com"
    is_admin
  end

  def authorize
    unless admin?
      flash[:error] = "Unauthorized access"
      redirect_to url_for("/")
    end
  end

  private
  def current_entity(logtag=nil)
    session_entity_id = session[Constants::SESSION_ENTITY_ID]
    Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}, current_entity:#{logtag}, session_entity_id:#{session_entity_id}")
    @current_entity = Entity.find(session_entity_id) if session_entity_id
    if !@current_entity.nil?
      @current_entity.reload
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}, current_entity:#{logtag}, @current_entity.inspect:#{@current_entity.inspect}")
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}current_entity:#{logtag}, @current_entity.endPoints.inspect:#{@current_entity.endPoints.inspect}")
    end # end if !@current_entity.nil?
    @current_entity
  end

  def logged_in
    unless current_entity
      flash[:error] = "Unauthorized access"
      redirect_to url_for("/")
    end
  end

#20111023SOLN#2  def redirect_not_logged_in(redirect_url)
#20111023SOLN#2    unless current_entity
#20111023SOLN#2      # CODE: base64 encode redirect_url
#20111023SOLN#2      redirect_to "/log_in?#{Constants::REDIRECT_URL}=#{redirect_url}")
#20111023SOLN#2    end # end unless current_entity
#20111023SOLN#2  end # end def redirect_not_logged_in

if Rails.env.production?
#  ENV['GROUP_PII'] = '9%3d%3d%3dlabutan'
#  ENV['GROUP_PII'] = '9%3d%3d%3dcrocs'
  ENV['GROUP_PII'] = '9%3d%3d%3dwatari'
else
  ENV['GROUP_PII'] = '28%3d%3d%3dwatari'
end

end
