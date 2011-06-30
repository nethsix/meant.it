require 'constants'
require 'controller_helper'

class FindAny < ApplicationController
# NOTE: If we use ActionController::Metal, we get error
# no default template defined when we use :layout with render.
# We also need to include AbstractController::Layouts otherwise
# it cannot understand :layout => true, i.e., it'll interpret as
# layout name.

#class FindAny < ActionController::Metal
#  include ActionController::Rendering
#  include AbstractController::Layouts

  append_view_path "#{Rails.root}/app/views/" 

  def index
    logtag = ControllerHelper.gen_logtag
    find_any_input = params[Constants::FIND_ANY_INPUT]
    if !find_any_input.nil?
      decoded_find_any_input = URI::decode(find_any_input)
      decoded_find_any_input.chomp!
      decoded_find_any_input.strip!
    else
      decoded_find_any_input = nil
    end # end if !find_any_input.nil?
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, decoded_find_any_input:#{decoded_find_any_input}")
    if decoded_find_any_input.nil? or decoded_find_any_input.empty?
      render and return
    else
      ControllerHelper.parse_meant_it_input(decoded_find_any_input)
      # Currently we're only interested in the tag_str
      # CODE!!! We should be able to find relationships, etc.
      
      # Check if it is a pii
      @pii = Pii.find_by_pii_value(decoded_find_any_input)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, @pii.inspect:#{@pii.inspect}")
      if !@pii.nil?
        render "piis/show_pii_details", :layout => true, :locals => { :notice => nil }
        return
      end # end if @pii.nil?
      # Check if they are tags
      tags_arr = decoded_find_any_input.split
      @endPoint_arr = EndPoint.tagged(tags_arr)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, find tags, @endPoint_arr.inspect:#{@endPoint_arr.inspect}")
      if !@endPoint_arr.nil? and !@endPoint_arr.empty?
        render "end_points/show_end_points", :layout => true, :locals => { :notice => nil }
        return
      end # end if !@endPoint_arr.nil?
      
      @endPoint_arr = EndPoint.where("nick = ?", decoded_find_any_input)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, find nicks, @endPoint_arr.inspect:#{@endPoint_arr.inspect}")
      if !@endPoint_arr.nil?
        render "end_points/show_end_points", :layout => true, :locals => { :notice => nil }
        return
      end # end if !@endPoint_arr.nil?
    end # end if decoded_find_any_input.nil? or decoded_find_any_input.empty?
  end # end def index

#  def self.call(env)
#    [200, {}, ["Thanks!"]]
#  end # end def self.call
end # end class FindAny
