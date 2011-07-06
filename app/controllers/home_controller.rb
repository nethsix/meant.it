class HomeController < ApplicationController
  def index
    render :layout => "find_any"
  end

  def why
    render "why", :layout => true
  end

  def learn_find
    render "learn_find", :layout => true
  end

  def learn_send
    render "learn_send", :layout => true
  end

  def message_types
    render "message_types", :layout => true
  end
end
