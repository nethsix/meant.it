class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :admin?
  protected
  def admin?
    false
  end

  def authorize
    unless admin?
      flash[:error] = "Unauthorized access"
      redirect_to url_for("/")
      false
    end
  end
end
