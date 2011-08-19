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

  def group
    render "group", :layout => false
  end

  def like
    render "like", :layout => false
  end

  def group_diy
    render "group_diy", :layout => false
  end
end
