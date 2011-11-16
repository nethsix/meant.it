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

  def campaigns
# Use this eventually when we have APIs for everything, i.e., call the
# API from the page using JSON
#CODE20111116    render "public/campaigns/#{params[:name]}", :layout => false
p "!!!!!!params[:name]:#{params[:name]}!!!!!"
    if !params[:predir].nil?
      render "/home/campaigns/#{params[:predir]}/#{params[:name]}", :layout => false
    else
      render "/home/campaigns/#{params[:name]}/#{params[:name]}", :layout => false
    end # end if params[:name].match(/^general/)
  end # end def campaigns
end
