class SessionsController < ApplicationController

  before_filter :logged_in, :only => [:manage]

  def new
  end

  def manage
    logtag = ControllerHelper.gen_logtag
    respond_to do |format|
      format.html # render 
    end
  end # end def manage

  def create  
    logtag = ControllerHelper.gen_logtag
    login_name = params[:session][:login_name]
    pword = params[:session][:password]
    entity = Entity.authenticate(login_name, pword)  
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, login_name:#{login_name}, entity.inspect:#{entity.inspect}")
    new_entity = nil
    if entity
      session[:entity_id] = entity.id
      redirect_to root_url, :notice => "Logged in!"
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
      session[:entity_id] = new_entity.id
      redirect_to root_url, :notice => "Welcome '#{new_entity.login_name}'!"
    else
      redirect_to root_url, :alert => "Re-captcha failed. User '#{params[:session][:login_name]}' not created!"
    end # end if verify_recaptcha
  end # end def verify_captcha

  def destroy  
    session[:entity_id] = nil  
    redirect_to root_url, :notice => "Logged out!"  
  end 
end
