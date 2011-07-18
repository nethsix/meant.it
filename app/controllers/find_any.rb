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

  PII_OBJ = :pii_obj
  PII_IDX = :pii_idx

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
      # We stop checking for pii and ep when ep_count = 2
      pii_str = explicit_pii_arr.shift
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, #1 pii_str:#{pii_str}")
      # Stores pii and ep we collect along the way
      pii_ep_arr = []
      pii = nil
      pii = Pii.find_by_pii_value(pii_str) if !pii_str.nil?
      if !pii.nil?
        # We keep track of where we find pii so that we know which is
        # sender/receiver.  We may find receiver first since sender can
        # be just a nick
        pii_str_idx = decoded_find_any_input.index(pii_str)
        pii_ep_arr << { PII_OBJ => pii, PII_IDX => pii_str_idx }
      end # end if !pii.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, #1 pii.inspect:#{pii.inspect}")
      pii_str = explicit_pii_arr.shift 
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, #2 pii_str:#{pii_str}")
      pii = nil
      pii = Pii.find_by_pii_value(pii_str) if !pii_str.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, #2 pii.inspect:#{pii.inspect}")
      if !pii.nil?
        pii_str_idx = decoded_find_any_input.index(pii_str)
        pii_ep_arr << { PII_OBJ => pii, PII_IDX => pii_str_idx }
      end # end if !pii.nil?
      parsed_find_any_tags_arr = parsed_find_any_hash[ControllerHelper::MEANT_IT_INPUT_TAGS_ARR]
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag},  initial parsed_find_any_tags_arr:#{parsed_find_any_tags_arr.inspect}")
      # Look for message_type
      message_type = nil
      origin_message_type = nil
      parsed_find_any_tags_arr.each { |tag_elem|
        message_type_idx = MessageTypeMapper.get_all_message_types.index(tag_elem)
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, MessageTypeMapper tag_elem:#{tag_elem}")
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, MessageTypeMapper.get_all_message_types:#{MessageTypeMapper.get_all_message_types.inspect}")
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, MessageTypeMapper message_type, message_type_idx:#{message_type_idx}")
        # Get the DRY message_type
        if !message_type_idx.nil?
          message_type = MessageTypeMapper.get_message_type(tag_elem)
          origin_message_type = tag_elem
        end # end if !message_type_idx.nil?
      } # end parsed_find_any_tags_arr ...
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, after MessageTypeMapper message_type, remaining parsed_find_any_tags_arr:#{parsed_find_any_tags_arr.inspect}")
      if message_type.nil?
        parsed_find_any_tags_arr.each { |tag_elem|
          message_type_idx = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_TYPE_ENUM.index(tag_elem)
          if !message_type_idx.nil?
            message_type = tag_elem
            origin_message_type = tag_elem
          end # end if !message_type_idx.nil?
        } # end parsed_find_any_tags_arr ...
      end # end if message_type.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, message_type:#{message_type}")
      parsed_find_any_tags_arr.delete(origin_message_type)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, after MeantItMessageTypeValidator message_type, remaining parsed_find_any_tags_arr:#{parsed_find_any_tags_arr.inspect}")
      # Maybe one of the tag is pii
      found_arr = []
      parsed_find_any_tags_arr.each { |tag_elem|
        break if pii_ep_arr.size >= 2
        pii = Pii.find_by_pii_value(tag_elem)
        if !pii.nil?
          pii_str_idx = decoded_find_any_input.index(pii.pii_value)
          found_arr << { PII_OBJ => pii, PII_IDX => pii_str_idx }
          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, finding pii from tags, pii.inspect:#{pii.inspect}")
        end # end if !pii.nil?
      } # end parsed_find_any_tags_arr.each ...
      pii_ep_arr += found_arr
      found_arr.each { |found_elem|
        parsed_find_any_tags_arr.delete(found_elem[PII_OBJ].pii_value)
      } # found_arr.each ...
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, after get pii from tags, remaining parsed_find_any_tags_arr:#{parsed_find_any_tags_arr.inspect}")
      found_arr = []
      # Maybe one of them tag is nick
      parsed_find_any_tags_arr.each { |tag_elem|
        break if pii_ep_arr.size >= 2
        ep_arr = EndPoint.where("nick = ?", tag_elem)
        if !ep_arr.nil? and !ep_arr.empty?
          ep_idx = decoded_find_any_input.index(ep_arr[0].nick)
          pii_ep_arr << { PII_OBJ => ep_arr, PII_IDX => ep_idx }
          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, finding ep from tags, ep_arr.inspect:#{ep_arr.inspect}")
        end # end if !ep_arr.nil? and !ep_arr.empty?
      } # end parsed_find_any_tags_arr.each ...
      pii_ep_arr += found_arr
      found_arr.each { |found_elem|
        parsed_find_any_tags_arr.delete(found_elem[PII_OBJ][0].nick)
      } # found_arr.each ...
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, after find ep from tags, remaining parsed_find_any_tags_arr:#{parsed_find_any_tags_arr.inspect}")
      tags_arr = parsed_find_any_tags_arr
      # Order pii/ep based on idx
      pii_ep_arr.sort! { |a,b| a[PII_IDX] <=> b[PII_IDX] }
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, sorted pii_ep_arr.inspect:#{pii_ep_arr.inspect}")
      sender_pii = nil
      receiver_pii = nil
      sender_ep_arr = []
      receiver_ep_arr = []
      pii_ep_arr.each { |pii_ep_elem|
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, pii_ep_elem[PII_OBJ].class:#{pii_ep_elem[PII_OBJ].class}")
        if pii_ep_elem[PII_OBJ].class == Pii
          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, pii_ep_elem:#{pii_ep_elem}")
          if sender_pii.nil? and sender_ep_arr.empty?
            sender_pii = pii_ep_elem[PII_OBJ]
            Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, assign to sender_pii")
          # We can just use else if we trust that elems is just 2
          elsif receiver_pii.nil? and receiver_ep_arr.empty?
            receiver_pii = pii_ep_elem[PII_OBJ]
            Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, assign to receiver_pii")
          end # end if sender_pii.nil?
        else
          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, pii_ep_elem:#{pii_ep_elem}")
          if sender_pii.nil? and sender_ep_arr.empty?
            sender_ep_arr = pii_ep_elem[PII_OBJ]
            Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, assign to sender_ep_arr")
          # We can just use else if we trust that elems is just 2
          elsif receiver_pii.nil? and receiver_ep_arr.empty?
            receiver_ep_arr = pii_ep_elem[PII_OBJ]
            Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, assign to receiver_ep_arr")
          end # end if sender_pii.nil?
        end # end if pii_ep_elem.class(Pii)
      } # end pii_ep_arr.each ...
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, sender_pii:#{sender_pii}, sender_ep_arr:#{sender_ep_arr}, receiver_pii:#{receiver_pii}, receiver_ep_arr:#{receiver_ep_arr}, message_type:#{message_type}")
      # At this point we have:
      # sender_pii/sender_ep_arr, receiver_pii/receiver_ep_arr, message_type,
      # tags_arr
      if sender_pii.nil? and sender_ep_arr.empty? and receiver_pii.nil? and receiver_ep_arr.empty? # regardless of message_type
        # These are all just tags!!!
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, show endpoint with tags_arr.inspect:#{tags_arr.inspect}")
        @endPoint_arr = EndPoint.tagged(tags_arr)
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, show endpoint with tags, @endPoint_arr.inspect:#{@endPoint_arr.inspect}")
        if !@endPoint_arr.nil? and !@endPoint_arr.empty?
          if message_type.nil?
            render "end_points/show_end_points", :layout => "find_any", :locals => { :notice => nil, :find_any_input => decoded_find_any_input, :title_str => "End point(s) with <b>tag(s)</b>: <i>#{decoded_find_any_input}</i>" }
            return
          else
            # These are all just tags but with a message_type
            render "show_endpoints_with_message_type", :layout => "find_any", :locals => { :notice => nil, :message_type => message_type, :find_any_input => decoded_find_any_input }
            return
          end # end elsif !message_type.nil?
        else
          if !message_type.nil? and !message_type.empty?
            redirect_to "/meant_it_rels/show_by_message_type?#{Constants::MESSAGE_TYPE_INPUT}=#{message_type}"
            return
          else
            error_msg = "We're sorry but no end points possess all the tags described"
            render "home/index", :layout => true, :locals => { :error_msg => error_msg, :find_any_input => decoded_find_any_input }
            return
          end # end if !message_type.nil?
        end # end if !@endPoint_arr.nil? ...
      elsif !sender_pii.nil? and sender_ep_arr.empty? and receiver_pii.nil? and receiver_ep_arr.empty? 
        @pii = sender_pii
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, show sender_pii => @pii.inspect:#{@pii.inspect}")
        if !@pii.nil? and message_type.nil?
          # Show the pii details
          render "piis/show_pii_details", :layout => "find_any", :locals => { :notice => nil, :find_any_input => decoded_find_any_input }
          return
        elsif !@pii.nil? and !message_type.nil?
          # Show the pii details with message_type
          render "show_pii_with_message_type", :layout => "find_any", :locals => { :notice => nil, :message_type => message_type, :find_any_input => decoded_find_any_input }
          return
        end # end elsif !message_type.nil?
      elsif sender_pii.nil? and !sender_ep_arr.empty? and receiver_pii.nil? and receiver_ep_arr.empty? 
        @endPoint_arr = sender_ep_arr
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, sender_ep_arr => @endPoint_arr.inspect:#{@endPoint_arr.inspect}")
        if message_type.nil?
          render "end_points/show_end_points_same_nick", :layout => "find_any", :locals => { :notice => nil, :find_any_input => decoded_find_any_input }
          return
        else
          # Get eps with those message_types
          if !@endPoint_arr.nil? and !@endPoint_arr.empty?
            render "show_endpoints_with_message_type", :layout => "find_any", :locals => { :notice => nil, :message_type => message_type, :find_any_input => decoded_find_any_input }
            return
          end # end if !@endPoint_arr.nil?
        end # end elsif !message_type.nil?
      elsif !sender_pii.nil? and !sender_ep_arr.empty? and receiver_pii.nil? and receiver_ep_arr.empty? 
        # NOT POSSIBLE since we only get either sender_pii or sender_eps
        Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, SHOULDN'T BE HERE, !sender_pii.nil? and !sender_ep_arr.empty? and receiver_pii.nil? and receiver_ep_arr.empty?")
      elsif sender_pii.nil? and sender_ep_arr.empty? and !receiver_pii.nil? and receiver_ep_arr.empty? 
        # NOT POSSIBLE if there are no senders then receivers can't exist
        Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, SHOULDN'T BE HERE, sender_pii.nil? and sender_ep_arr.empty? and !receiver_pii.nil? and receiver_ep_arr.empty?")
      elsif sender_pii.nil? and sender_ep_arr.empty? and receiver_pii.nil? and !receiver_ep_arr.empty? 
        # NOT POSSIBLE if there are no senders then receivers can't exist
        Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, SHOULDN'T BE HERE, sender_pii.nil? and sender_ep_arr.empty? and receiver_pii.nil? and !receiver_ep_arr.empty?")
      elsif !sender_pii.nil? and sender_ep_arr.empty? and !receiver_pii.nil? and receiver_ep_arr.empty? 
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, show sender_pii.inspect:#{sender_pii.inspect}, receiver_pii.inspect:#{receiver_pii.inspect}, message_type:#{message_type}")
        if message_type.nil?
            render "show_pii_pii.html.erb", :layout => "find_any", :locals => { :notice => nil, :sender_pii => sender_pii, :receiver_pii => receiver_pii, :find_any_input => decoded_find_any_input }
            return
        else
            render "show_pii_pii_with_message_type.html.erb", :layout => "find_any", :locals => { :notice => nil, :sender_pii => sender_pii, :receiver_pii => receiver_pii, :message_type => message_type, :find_any_input => decoded_find_any_input }
            return
        end # end if message_type.nil?
      elsif sender_pii.nil? and !sender_ep_arr.empty? and receiver_pii.nil? and !receiver_ep_arr.empty? 
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, show sender_nick:#{sender_ep_arr[0].nick}, receiver nick:#{receiver_ep_arr[0].nick}, message_type:#{message_type}")
        if message_type.nil?
            render "show_endpoints_endpoints.html.erb", :layout => "find_any", :locals => { :notice => nil, :sender_endPoints => sender_ep_arr, :receiver_endPoints => receiver_ep_arr, :find_any_input => decoded_find_any_input }
            return
        else
            render "show_endpoints_endpoints_with_message_type.html.erb", :layout => "find_any", :locals => { :notice => nil, :sender_endPoints => sender_ep_arr, :receiver_endPoints => receiver_ep_arr, :message_type => message_type, :find_any_input => decoded_find_any_input }
            return
        end # end if message_type.nil?
      elsif sender_pii.nil? and !sender_ep_arr.empty? and !receiver_pii.nil? and receiver_ep_arr.empty? 
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, show sender_nick:#{sender_ep_arr[0].nick}, receiver pii.inspect:#{receiver_pii.inspect}, message_type:#{message_type}")
        if message_type.nil?
            render "show_endpoints_pii", :layout => "find_any", :locals => { :notice => nil, :endPoints => sender_ep_arr, :pii=> receiver_pii, :find_any_input => decoded_find_any_input }
            return
        else
            render "show_endpoints_pii_with_message_type", :layout => "find_any", :locals => { :notice => nil, :endPoints => sender_ep_arr, :pii => receiver_pii, :message_type => message_type, :find_any_input => decoded_find_any_input }
            return
        end # end if message_type.nil?
      elsif !sender_pii.nil? and sender_ep_arr.empty? and receiver_pii.nil? and !receiver_ep_arr.empty? 
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, show sender pii.inspect:#{sender_pii.inspect}, receiver_nick:#{receiver_ep_arr[0].nick}, message_type:#{message_type}")
        if message_type.nil?
            render "show_endpoints_pii.html", :layout => "find_any", :locals => { :notice => nil, :endPoints => receiver_ep_arr, :pii=> sender_pii, :find_any_input => decoded_find_any_input }
            return
        else
            render "show_endpoints_pii_with_message_type", :layout => "find_any", :locals => { :notice => nil, :endPoints => receiver_ep_arr, :pii => sender_pii, :message_type => message_type, :find_any_input => decoded_find_any_input }
            return
        end # end if message_type.nil?
      else
        Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:index:#{logtag}, SHOULDN'T BE HERE!!!")
        flash[:notice] = "boohoo!!!"
        render "/"
      end # end if sender_pii.nil? ...
    end # end if decoded_find_any_input.nil? or decoded_find_any_input.empty?
  end # end def index

#  def self.call(env)
#    [200, {}, ["Thanks!"]]
#  end # end def self.call
end # end class FindAny
