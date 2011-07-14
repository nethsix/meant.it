class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_entity
    
  private
  def current_entity
    @current_entity ||= Entity.find(session[:entity_id]) if session[:entity_id]
  end
end
