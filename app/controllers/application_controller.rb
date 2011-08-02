class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_entity
  helper_method :logged_in
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
    false
  end

  def authorize
    unless admin?
      flash[:error] = "Unauthorized access"
      redirect_to url_for("/")
    end
  end

  private
  def current_entity
    @current_entity ||= Entity.find(session[Constants::SESSION_ENTITY_ID]) if session[Constants::SESSION_ENTITY_ID]
  end

  def logged_in
    unless current_entity
      flash[:error] = "Unauthorized access"
      redirect_to url_for("/")
    end
  end

if Rails.env.production?
  ENV['GROUP_PII'] = '9%3d%3d%3dlabutan'
else
  ENV['GROUP_PII'] = '25%3d%3d%3dlabutan'
end

end
