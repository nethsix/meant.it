require 'constants'
require 'validators'
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
      parsed_find_any_hash = ControllerHelper.parse_meant_it_input(decoded_find_any_input)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, parsed_find_any_hash.inspect:#{parsed_find_any_hash.inspect}")
      # If there is one explicit pii, i.e., with :xxx, or :xxxx:
      # or two explicit piis, get them.  NOTE: we treat the first pii
      # as sender the the latter as receiver.
      explicit_pii_arr = parsed_find_any_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII_ARR]
      sender_pii_str = explicit_pii_arr.shift
      sender_pii = Pii.find_by_pii_value(sender_pii_str) if sender_pii_str.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, sender_pii.inspect:#{sender_pii.inspect}")
      receiver_pii_str = explicit_pii_arr.shift 
      receiver_pii = Pii.find_by_pii_value(receiver_pii_str) if receiver_pii_str.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, receiver_pii.inspect:#{receiver_pii.inspect}")
      parsed_find_any_tags_arr = parsed_find_any_hash[ControllerHelper::MEANT_IT_INPUT_TAGS_ARR]
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag},  initial parsed_find_any_tags_arr:#{parsed_find_any_tags_arr}")
      # Look for message_type
      message_type = nil
      parsed_find_any_tags_arr.each { |tag_elem|
        message_type_idx = MessageTypeMapper.get_all_message_types.index(tag_elem)
        # Get the DRY message_type
        message_type = MessageTypeMapper.get_message_type(tag_elem) if !message_type_idx.nil?
      } # end parsed_find_any_tags_arr ...
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, after MessageTypeMapper message_type, remaining parsed_find_any_tags_arr:#{parsed_find_any_tags_arr}")
      if message_type.nil?
        parsed_find_any_tags_arr.each { |tag_elem|
          message_type_idx = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_TYPE_ENUM.index(tag_elem)
          message_type = tag_elem if !message_type_idx.nil?
        } # end parsed_find_any_tags_arr ...
      end # end if message_type.nil?
      parsed_find_any_tags_arr.delete(message_type)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, after MeantItMessageTypeValidator message_type, remaining parsed_find_any_tags_arr:#{parsed_find_any_tags_arr}")
      sender_ep_arr = []
      receiver_ep_arr = []
      if sender_pii.nil?
        # Maybe one of them tag is pii
        parsed_find_any_tags_arr.each { |tag_elem|
          sender_pii = Pii.find_by_pii_value(tag_elem)
          break if !sender_pii.nil?
        } # end parsed_find_any_tags_arr.each ...
        parsed_find_any_tags_arr.delete(sender_pii.pii_value) if !sender_pii.nil?
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, finding sender_pii from tags, sender_pii.inspect:#{sender_pii.inspect}")
      end # end if sender_pii.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, after sender_pii, remaining parsed_find_any_tags_arr:#{parsed_find_any_tags_arr}")
      if sender_pii.nil?
        # Maybe one of them tag is nick for sender_ep
        parsed_find_any_tags_arr.each { |tag_elem|
          sender_ep_arr = EndPoint.where("nick = ?", tag_elem)
          break if !sender_ep_arr.empty?
        } # end parsed_find_any_tags_arr.each ...
        parsed_find_any_tags_arr.delete(sender_ep_arr[0].nick) if !sender_ep_arr.empty?
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, finding sender_ep from tags, sender_ep_arr.inspect:#{sender_ep_arr.inspect}")
      end # end if sender_pii.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, after sender_ep_arr, remaining parsed_find_any_tags_arr:#{parsed_find_any_tags_arr}")
      if !sender_pii.nil? or !sender_ep_arr.empty?
        # Search for receiver if sender found otherwise if there 
        # are no piis, no eps among tags so don't bother
        parsed_find_any_tags_arr.each { |tag_elem|
          receiver_pii = Pii.find_by_pii_value(tag_elem)
          break if !receiver_pii.nil?
        } # end parsed_find_any_tags_arr.each ...
        parsed_find_any_tags_arr.delete(receiver_pii.pii_value) if !receiver_pii.nil?
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, finding receiver_pii from tags, receiver_pii.inspect:#{receiver_pii.inspect}")
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, after receiver_pii, remaining parsed_find_any_tags_arr:#{parsed_find_any_tags_arr}")
        if receiver_pii.nil?
          # Maybe one of the tag is nick for receiver_ep
          parsed_find_any_tags_arr.each { |tag_elem|
            receiver_ep_arr = EndPoint.where("nick = ?", tag_elem)
            break if !receiver_ep_arr.empty?
          } # end parsed_find_any_tags_arr.each ...
          parsed_find_any_tags_arr.delete(receiver_ep_arr[0].nick) if !receiver_ep_arr.empty?
          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, finding receiver_ep from tags, receiver_ep_arr.inspect:#{receiver_ep_arr.inspect}")
        end # end if receiver_pii.nil?
      end # end if !sender_pii.nil? ....
      tags_arr = parsed_find_any_tags_arr
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, after receiver_ep_arr remaining parsed_find_any_tags_arr:#{parsed_find_any_tags_arr}")
      # At this point we have:
      # sender_pii/sender_ep_arr, receiver_pii/receiver_ep_arr, message_type,
      # tags_arr
      if sender_pii.nil? and sender_ep_arr.empty? and receiver_pii.nil? and receiver_ep_arr.empty? # regardless of message_type
        # These are all just tags!!!
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, show endpoint with tags_arr.inspect:#{tags_arr.inspect}")
        @endPoint_arr = EndPoint.tagged(tags_arr)
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, show endpoint with tags, @endPoint_arr.inspect:#{@endPoint_arr.inspect}")
        if message_type.nil?
          if !@endPoint_arr.nil? and !@endPoint_arr.empty?
            render "end_points/show_end_points", :layout => true, :locals => { :notice => nil }
            return
          end # end if !@endPoint_arr.nil?
        else
          # These are all just tags but with a message_type
        end # end elsif !message_type.nil?
      elsif !sender_pii.nil? and sender_ep_arr.empty? and receiver_pii.nil? and receiver_ep_arr.empty? 
        if message_type.nil?
          # Show the pii details
          @pii = sender_pii
          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, show sender_pii => @pii.inspect:#{@pii.inspect}")
          render "piis/show_pii_details", :layout => true, :locals => { :notice => nil }
          return
        else
          # Get pii with those message_types
          # CODE!!!!
        end # end elsif !message_type.nil?
      elsif sender_pii.nil? and !sender_ep_arr.empty? and receiver_pii.nil? and receiver_ep_arr.empty? 
        if message_type.nil?
          @endPoint_arr = sender_ep_arr
          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, sender_ep_arr => @endPoint_arr.inspect:#{@endPoint_arr.inspect}")
          render "end_points/show_end_points", :layout => true, :locals => { :notice => nil }
          return
        else
          # Get eps with those message_types
          # CODE!!!!
        end # end elsif !message_type.nil?
      elsif !sender_pii.nil? and !sender_ep_arr.empty? and receiver_pii.nil? and receiver_ep_arr.empty? 
         # NOT POSSIBLE since we only get either sender_pii or sender_eps
      elsif sender_pii.nil? and sender_ep_arr.empty? and !receiver_pii.nil? and receiver_ep_arr.empty? 
        # NOT POSSIBLE if there are no senders then receivers can't exist
      elsif sender_pii.nil? and sender_ep_arr.empty? and receiver_pii.nil? and !receiver_ep_arr.empty? 
        # NOT POSSIBLE if there are no senders then receivers can't exist
      elsif !sender_pii.nil? and sender_ep_arr.empty? and !receiver_pii.nil? and receiver_ep_arr.empty? 
        # We can deal with this CODE!!!
      elsif sender_pii.nil? and !sender_ep_arr.empty? and receiver_pii.nil? and !receiver_ep_arr.empty? 
        # We need user intervention to deal with this CODE!!!
      elsif sender_pii.nil? and !sender_ep_arr.empty? and !receiver_pii.nil? and receiver_ep_arr.empty? 
        # We need user intervention to deal with this CODE!!!
      elsif !sender_pii.nil? and sender_ep_arr.empty? and receiver_pii.nil? and !receiver_ep_arr.empty? 
        # We need user intervention to deal with this CODE!!!
      end # end if sender_pii.nil? ...
    end # end if decoded_find_any_input.nil? or decoded_find_any_input.empty?
  end # end def index

#  def self.call(env)
#    [200, {}, ["Thanks!"]]
#  end # end def self.call
end # end class FindAny
