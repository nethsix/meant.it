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
   # As of 20111126, we will leave this here since if we move it out
   # to public directory then we need to sync things such as url parm names
   # instead of being able to use <%= Constants::MESSAGE_TYPE_INPUT %>, etc.
   # Instead, to re-use the page, users can just 'show/display source' and
   # use the code there.
    if !params[:predir].nil?
      render "/home/campaigns/#{params[:predir]}/#{params[:name]}", :layout => false
    else
      render "/home/campaigns/#{params[:name]}/#{params[:name]}", :layout => false
    end # end if params[:name].match(/^general/)
  end # end def campaigns
end
