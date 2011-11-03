require 'validators'
require 'date'
require 'set'

module ControllerHelper
  LOGTAG_MAX = 2**32

  MEANT_IT_INPUT_MESSAGE = :message
  MEANT_IT_INPUT_MESSAGE_ARR = :message_arr
  MEANT_IT_INPUT_RECEIVER_PII = :receiver_pii
  MEANT_IT_INPUT_RECEIVER_PII_ARR = :receiver_pii_arr
  MEANT_IT_INPUT_TAGS_ARR = :tags_arr
  MEANT_IT_INPUT_RECEIVER_NICK = :receiver_nick
  MEANT_IT_INPUT_TAGS = :tags

  SQL_ORDER_ENUM = [Constants::SQL_COUNT_ORDER_ASC, Constants::SQL_COUNT_ORDER_DESC]
  def self.sql_validate_order(order_str, default_order)
    default_order ||= SQL_ORDER_NUM[1]
    if !order_str.nil?
      cleansed_order_str = SQL_ORDER_ENUM.include?(order_str.downcase.strip) ? order_str : default_order
    else
      cleansed_order_str = default_order
    end # end if !order_str.nil?
    cleansed_order_str
  end # end def self.sql_validate_order(order_str)

  def self.validate_email(email_str)
    is_email = false
    if !email_str.nil?
      email_match = email_str.match(/.+@.+\..+/)
      is_email = true if !email_match.nil?
      is_email
    end # end if !email_str.nil?
  end # end def self.validate_email

  def self.nickify_str(str)
    nick = str.gsub(' ', '_')
    nick
  end # end def self.nickify_pii

  def self.validate_number(num_str, default_num)
    default_num ||= nil
    if !num_str.nil?
      cleansed_num_str = num_str.strip.match(/^\d+$/) ? num_str : default_num
    else
      cleansed_num_str = default_num
    end # end if !num_str.nil?
    cleansed_num_str
  end # end def def self.validate_number(num_str)

  AUTO_ENTITY_DOMAIN_ENTITY_ID = 1
  def self.auto_entity_domain?(pii_str)
    pii_match_arr = nil
    pii_match_arr = pii_str.match(/(\d+?)#{Constants::ENTITY_DOMAIN_MARKER}/) if !pii_str.nil?
    pii_match_arr
  end # end def self.auto_entity_domain?

  def self.gen_logtag
    rand(LOGTAG_MAX)
  end # end def gen_logtag

  def self.parse_message_type_from_email_addr(email_addr, logtag = nil)
    message_type_str = nil
    email_addr_match_arr = nil
    # NOTE: email_addr may be long for, i.e., "hello kitty <hello_kitty@sanrio.com>"
    email_hash = parse_email(email_addr)
    short_email_addr = email_hash[EMAIL_STR]
    email_addr_match_arr = short_email_addr.match /(.+)@.+\..+/ if !short_email_addr.nil?
    if email_addr_match_arr.nil?
      message_type_str = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_THANK
    else
      message_type_str = MessageTypeMapper.get_message_type(email_addr_match_arr[1])
    end # end if email_addr_match_arr.nil?
    message_type_str
  end # end def self.parse_message_type_from_email

  def self.parse_meant_it_input(input_str, logtag = nil)
    input_str_downcase = input_str.downcase
    input_str_dup = input_str.dup if !input_str.nil?
    input_str_dup.downcase! if !input_str_dup.nil?
    result_hash = {}
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, input_str_dup:#{input_str_dup}")
    # Determine nick, :xxx, :yyy, tags
    # Get those strings enclosed with quotes ' or "
    # NOTE: scan returns [['abc'], ['def']... thus we use collect
    # to convert to [abc, def, ...]
    # Nick is the first tag, no spaces are allowed for nick
    # Message is enclosed within ;
    message_str_arr = input_str_dup.scan(/;(.*);/).collect { |elem| elem[0] }
    message_str = message_str_arr[0]
    message_str.strip! if !message_str.nil?
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, message_str:#{message_str}")
    message_str_arr.each { |msg_elem| 
      input_str_dup.sub!(/;#{Regexp.escape(msg_elem)};/, '')
      msg_elem.strip!
    }
    result_hash[MEANT_IT_INPUT_MESSAGE_ARR] = message_str_arr
    result_hash[MEANT_IT_INPUT_MESSAGE] = message_str
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, after message_str remove, input_str_dup:#{input_str_dup}")
    # Check for colon enclosed receiver pii
    receiver_pii_str_arr = input_str_dup.scan(/:(.*?):/).collect { |elem| elem[
0] }
    receiver_pii_str_idx = input_str_downcase.index(":#{receiver_pii_str_arr[0]}") if !receiver_pii_str_arr.empty?
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, receiver_pii_str_arr:#{receiver_pii_str_arr.inspect}, receiver_pii_str_idx:#{receiver_pii_str_idx}")
    receiver_pii_str_arr.each { |receiver_pii_elem| 
      input_str_dup.sub!(/:#{Regexp.escape(receiver_pii_elem)}:/, '')
      receiver_pii_elem.strip!
    }
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, after receiver_pii_str_arr remove, input_str_dup:#{input_str_dup}")
    # Check for pii starting with colon
    receiver_pii_str_arr2 = input_str_dup.scan(/:(.*?)\s/).collect { |elem| elem[0] }
    # We need the \s otherwise ':xxx ' will also match, e.g.,
    # ':xxx ;thanks;' will be reduced to ':xxx ' which will match this
    receiver_pii_str_arr2 += input_str_dup.scan(/\s:(.*?)$/).collect { |elem| elem[0] }
    # Match the word itself, e.g., ':xxx'
    receiver_pii_str_arr2 += input_str_dup.scan(/^:(.*?)$/).collect { |elem| elem[0] }
    receiver_pii_str_idx2 = input_str_downcase.index(":#{receiver_pii_str_arr2[0]}") if !receiver_pii_str_arr2.empty?
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, receiver_pii_str_arr2:#{receiver_pii_str_arr2.inspect}, receiver_pii_str_idx2:#{receiver_pii_str_idx2}")
    get_from_this_receiver_pii_arr = nil
    if receiver_pii_str_idx.nil? and !receiver_pii_str_idx2.nil?
      get_from_this_receiver_pii_arr = receiver_pii_str_arr2
    elsif !receiver_pii_str_idx.nil? and receiver_pii_str_idx2.nil?
      get_from_this_receiver_pii_arr = receiver_pii_str_arr
    elsif !receiver_pii_str_idx.nil? and !receiver_pii_str_idx2.nil?
      get_from_this_receiver_pii_arr = receiver_pii_str_idx < receiver_pii_str_idx2 ? receiver_pii_str_arr : receiver_pii_str_arr2
    end # end elsif !receiver_pii_str_idx.nil?
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, get_from_this_receiver_pii_arr:#{get_from_this_receiver_pii_arr.inspect}")
    receiver_pii_str_arr2.each { |receiver_pii_elem| 
      input_str_dup.sub!(/:#{Regexp.escape(receiver_pii_elem)}/, '')
      receiver_pii_elem.strip!
    }
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, after receiver_pii_str_arr2 remove, input_str_dup:#{input_str_dup}")
    result_hash[MEANT_IT_INPUT_RECEIVER_PII_ARR] = receiver_pii_str_arr + receiver_pii_str_arr2
    receiver_pii_str = get_from_this_receiver_pii_arr[0] if !get_from_this_receiver_pii_arr.nil?
    single_quote_tag_arr = input_str_dup.scan(/'(.*?)'/).collect { |elem| elem[0] }
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, single_quote_tag_arr.inspect:#{single_quote_tag_arr.inspect}")
    # Remove those quoted tags since we've processed them
    single_quote_tag_arr.each { |tag_elem| 
      input_str_dup.sub!(/'#{Regexp.escape(tag_elem)}'/, '')
      tag_elem.strip!
    }
    double_quotes_tag_arr = input_str_dup.scan(/"(.*?)"/).collect { |elem| elem[0] }
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, double_quotes_tag_arr.inspect:#{double_quotes_tag_arr.inspect}")
    double_quotes_tag_arr.each { |tag_elem|
      input_str_dup.sub!(/"#{Regexp.escape(tag_elem)}"/, '')
      tag_elem.strip!
    }
    tag_str_arr = single_quote_tag_arr + double_quotes_tag_arr
    input_str_arr = input_str_dup.split
    input_str_arr.each { |input_elem|
      input_elem.strip!
    } 
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, stripped input_str_arr.inspect:#{input_str_arr.inspect}")
    result_hash[MEANT_IT_INPUT_TAGS_ARR] = input_str_arr.clone + tag_str_arr.clone
    if receiver_pii_str.nil?
      # Check for an email on the remaining input_str
      receiver_pii_arr = input_str_arr.find_all { |str| str.match(/.+@.+\..+/) }
      receiver_pii_str = receiver_pii_arr[0] if !receiver_pii_arr.empty?
      receiver_pii_arr.each { |rec_pii_elem|
        input_str_arr.delete(rec_pii_elem)
      } # end receiver_pii_arr.each ...
    end # if receiver_pii_str.nil?
    receiver_pii_str.strip! if !receiver_pii_str.nil?
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, receiver_pii_str:#{receiver_pii_str}")
    result_hash[MEANT_IT_INPUT_RECEIVER_PII] = receiver_pii_str
    receiver_pii_str_hash = self.get_pii_hash(receiver_pii_str)
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, receiver_pii_str_hash.inspect:#{receiver_pii_str_hash.inspect}")
    # NOTE: the diff between receiver_pii_str and receiver_pii_value_str
    # is, e.g., the $ at the end to indicate whether the pii should be
    # hidden
    receiver_pii_value_str = receiver_pii_str_hash[ControllerHelper::PII_VALUE_STR]
    receiver_pii_hide = receiver_pii_str_hash[ControllerHelper::PII_HIDE]
    if !receiver_pii_value_str.nil?
      if self.validate_email(receiver_pii_value_str)
        # If receiver_pii is email then the nick is the next keyword
        # NOTE: email is has pii_hide true so we need a nick
        receiver_nick_str = input_str_arr.shift
        receiver_nick_str.strip! if !receiver_nick_str.nil?
      elsif !self.validate_email(receiver_pii_value_str) and receiver_pii_hide == PiiHideTypeValidator::PII_HIDE_TRUE
        # If receiver_pii is not email but the pii is marked as
        # hide then we need a nick
        receiver_nick_str = input_str_arr.shift
        receiver_nick_str.strip! if !receiver_nick_str.nil?
      else
        # If receiver_pii is not email but the pii is not marked as
        # hide then it is also the nick
        receiver_nick_str = ControllerHelper.nickify_str(receiver_pii_value_str)
      end # end if self.validate_email(receiver_pii_str)
    else
      receiver_nick_str = input_str_arr.shift
      receiver_nick_str.strip! if !receiver_nick_str.nil?
    end # end if !receiver_pii_value_str.nil?
    result_hash[MEANT_IT_INPUT_RECEIVER_NICK] = receiver_nick_str
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, receiver_nick_str:#{receiver_nick_str}")
    tag_str_arr += input_str_arr
    tag_str_arr.uniq!
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:parse_meant_it_input:#{logtag}, tag_str_arr.inspect:#{tag_str_arr.inspect}")
    result_hash[MEANT_IT_INPUT_TAGS] = tag_str_arr
    result_hash
  end # end def.parse_meant_it_text

  def self.find_person_by_id(person_id, logtag=nil)
    person = nil
    begin
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_person_by_id:#{logtag}, person_id:#{person_id}")
      person = Person.find(person_id)
    rescue Exception => e
    end # end cannot find person from couchdb
    if person.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_person_by_id:#{logtag}, person find triggered exception, e.inspect:#{e.inspect}")
      # Use sql instead of couchdb
      person = EntityDatum.find_by_id(person_id)
    end # end if person.nil?
    person
  end # end def self.find_person_by_id

  def self.find_person_by_email(name, email, logtag=nil)
    person = nil
    begin
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_person_by_email:#{logtag}, name:#{name}, email:#{email}")
      person = Person.find_by_email(email)
    rescue Exception => e
    end # end cannot find person from couchdb
    if person.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_person_by_email:#{logtag}, person find triggered exception, e.inspect:#{e.inspect}")
      # Use sql instead of couchdb
#20111026WTF      person = EntityDatum.find_by_email(:email => email)
      person = EntityDatum.find_by_email(email)
    end # end if person.nil?
    person
  end # end def self.find_person_by_email(name, email, logtag=nil)

  def self.find_or_create_person_by_email(name, email, logtag=nil)
    new_person = nil
    begin
      # Create propertyId
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_person_by_email:#{logtag}, name:#{name}, email:#{email}")
      new_person = Person.find_by_email(email)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_person_by_email:#{logtag}, find_by_email new_person:#{new_person.inspect}")
      if new_person.nil?
        new_person = Person.create(:name => name, :email => email)
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_person_by_email:#{logtag}, create new_person:#{new_person.inspect}")
      end # end if new_person.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_person_by_email:#{logtag}, new_person.errors:#{new_person.errors.inspect}")
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_person_by_email:#{logtag}, new_person:#{new_person.inspect}")
   rescue Exception => e
      # Usually because couchdb is not there
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_person_by_email:#{logtag}, person find/create triggered exception, e.inspect:#{e.inspect}")
      # Use sql instead of couchdb
#20111026WTF      new_person = EntityDatum.find_or_create_by_email(:email => email)
      new_person = EntityDatum.find_or_create_by_email(email)
   end # end find/create person
   new_person
  end # end def self.find_or_create_person_by_email

  # Email can be of long format "hello kitty" <hello_kitty@sanrio.com>
  EMAIL_NICK_STR = :email_nick_str
  EMAIL_STR = :email_str
  def self.parse_email(email_str)
    email_str_match_arr = email_str.match(/(.*)<(.*)>/)
    email_nick_str = email_str_match_arr[1].strip if !email_str_match_arr.nil?
    email_nick_str = strip_quotes(email_nick_str)
    # NOTE: <kuromi@sanrio.com> will give email_nick_str = '' instead of nil
    if email_nick_str.nil? or email_nick_str.empty?
      email_nick_str = nil 
    else
      # We don't want space in nicks
      email_nick_str.sub!(' ', '_')
    end # end if email_nick_str.nil? or email_nick_str.empty?
    email_str = email_str_match_arr[2].strip if !email_str_match_arr.nil?
    if (email_str_arr = email_str.match(/(.+)#{Constants::MEANT_IT_PII_SUFFIX}/))
      # Not an email but a pii
      email_str = email_str_arr[1]
    elsif email_str_arr.nil? or email_str_arr.empty?
      # Check if it's an email
      email_str_arr = email_str.match(/(.+?)@(.+)\.(.+?)/)
      email_str = nil if email_str_arr.nil?
    end # end if !email_str.index(Constants::MEANT_IT_PII_SUFFIX).nil?
#    email_nick_str ||= email_str
    { EMAIL_NICK_STR => email_nick_str, EMAIL_STR => email_str }
  end # end self.parse_email

  PII_VALUE_STR = :pii_value_str
  PII_TYPE = :pii_type
  PII_HIDE = :pii_hide
  def self.get_pii_hash(initial_pii_value_str)
    final_pii_value_str = initial_pii_value_str
    pii_type = PiiTypeValidator::PII_TYPE_GLOBAL
    pii_hide = PiiHideTypeValidator::PII_HIDE_FALSE
    if !final_pii_value_str.nil?
      if (match_arr = initial_pii_value_str.match(/.+@.+\..+/))
        pii_type = PiiTypeValidator::PII_TYPE_EMAIL
        pii_hide = PiiHideTypeValidator::PII_HIDE_TRUE
      elsif (match_arr = initial_pii_value_str.match(/(.+)\$(.*)/))
        pii_type = match_arr[2]
        pii_hide = PiiHideTypeValidator::PII_HIDE_TRUE
        final_pii_value_str = match_arr[1]
        if PiiTypeValidator::PII_TYPE_ENUM.index(pii_type).nil?
          pii_type = PiiTypeValidator::PII_TYPE_OTHER
        end # end if PiiTypeValidator::PII_TYPE_ENUM.index(pii_type)
      end # end if initial_pii_value_str.match ...
      if initial_pii_value_str.match(/.+\$$/)
        # Ends with $ then we set to hide
        pii_hide = PiiHideTypeValidator::PII_HIDE_TRUE
      end # end if initial_pii_value_str.match ...
    end # end if !final_pii_value_str.nil?
    { PII_VALUE_STR => final_pii_value_str, PII_TYPE => pii_type, PII_HIDE => pii_hide }
  end # end def self.get_pii_hash

  def self.strip_quotes(input_str)
    stripped_input_str = nil
    if !input_str.nil?
      input_match_arr = input_str.match(/"(.*)"/)
      if input_match_arr.nil?
        input_match_arr = input_str.match(/'(.*)'/)
      end # end if input_match_arr.empty? ...
      stripped_input_str = input_match_arr[1] if !input_match_arr.nil?
      stripped_input_str ||= input_str
    end # end if !input_str.nil?
    stripped_input_str
  end # end def self.strip_quotes

  def self.ep_from_mir_uniqSrcEndPoints(meantItRels)
    sender_arr = meantItRels.collect { |mir| mir.src_endpoint }
    sender_arr.compact!
    sender_arr.uniq!
    sender_arr
  end # end def self.ep_from_mir_uniqSrcEndPoints


  def self.ep_from_mir_uniqDstEndPoints(meantItRels)
    receiver_arr = meantItRels.collect { |mir| mir.dst_endpoint }
    receiver_arr.compact!
    receiver_arr.uniq!
    receiver_arr
  end # end def self.ep_from_mir_uniqDstEndPoints

  def self.gen_srcMsgDst_key(src, msg_type, dst)
    hash_key = "#{src}#{msg_type}#{dst}"
    hash_key
  end # end def self.gen_hash_key

  def self.ungen_srcMsgDst_key(key)
    match_arr = key.match(/(\d+)([A-Za-z]+)(\d+)/)
    match_arr
  end # end def self.gen_hash_key

  def self.mir_from_mir_uniqSrcEndPoints(meantItRels)
    src_uniq_hash = {}
    meantItRels.each { |mir| 
      hash_key = mir.src_endpoint_id
      src_uniq_hash[hash_key] ||= []
      src_uniq_hash[hash_key] << mir
    } # end meantItRels.each ...
    src_uniq_hash
  end # end def self.mir_from_mir_uniqDstEndPoints

  def self.mir_from_mir_uniqDstEndPoints(meantItRels)
    dst_uniq_hash = {}
    meantItRels.each { |mir| 
      hash_key = mir.dst_endpoint_id
      dst_uniq_hash[hash_key] ||= []
      dst_uniq_hash[hash_key] << mir
    } # end meantItRels.each ...
    dst_uniq_hash
  end # end def self.mir_from_mir_uniqDstEndPoints

  def self.mir_from_mir_uniqSrcMsgDstEndPoints(meantItRels)
    src_msg_dst_uniq_hash = {}
    meantItRels.each { |mir| 
      hash_key = gen_srcMsgDst_key(mir.src_endpoint_id, mir.message_type, mir.dst_endpoint_id)
      src_msg_dst_uniq_hash[hash_key] ||= []
      src_msg_dst_uniq_hash[hash_key] << mir
    } # end meantItRels.each ...
    src_msg_dst_uniq_hash
  end #end def self.mir_from_mir_uniqSrcDstEndPoints


  def self.mir_from_mir_messageType(meantItRels, message_type)
    meantItRels.find_all { |elem| elem.message_type == message_type }
  end # end def self.mir_from_mir_messageType

  def self.mir_from_ep_srcMeantItRels(endPoints)
    mirs = endPoints.collect { |s_ep_elem| s_ep_elem.srcMeantItRels if !s_ep_elem.srcMeantItRels.nil? }
    mirs.flatten!
    mirs
  end # end def self.mir_from_ep_srcMeantItRels

  def self.mir_from_ep_dstMeantItRels(endPoints)
    mirs = endPoints.collect { |d_ep_elem| d_ep_elem.dstMeantItRels if !d_ep_elem.dstMeantItRels.nil? }
    mirs.flatten!
    mirs
  end # end def self.mir_from_ep_dstMeantItRels

  def self.classified_mir_hash_on_message_type_from_mir(meantItRels)
    meantItRelTypeHash = {}
    meantItRels.each { |mi_elem|
      meantItRelTypeHash[mi_elem.message_type] ||= []
      meantItRelTypeHash[mi_elem.message_type] << mi_elem
    } # end meantItRels.each ...
    meantItRelTypeHash
  end # end def self.classified_mir_hash_on_message_type_from_mir

  def self.classified_mir_hash_on_message_type_from_classified_mir_hash_on_message_type_uniqDstEndPoints(meantItRelTypeHash)
   
    meantItRelTypeUniqHash = {}
    meantItRelTypeHash.each { |mi_type, mi_arr|
      uniqReceiverArr = []
      mi_arr.each { |mi_elem|
        if uniqReceiverArr.index(mi_elem.dst_endpoint).nil?
          meantItRelTypeUniqHash[mi_type] ||= []
          meantItRelTypeUniqHash[mi_type] << mi_elem 
          uniqReceiverArr << mi_elem.dst_endpoint
        end # end if uniqReceiverArr.index(mi_elem.dst_endpoint).nil?
      } # end mi_arr.each ...
    } # end meantItRelTypeHash.each ...
    meantItRelTypeUniqHash
  end # end def self.classified_mir_hash_on_message_type_from_classified_mir_hash_on_message_type_uniqDstEndPoints

  def self.mir_from_find_match_dstEndPoints(meantItRels, matchEndPoints_arr)
    match_mir_arr = meantItRels.find_all { |mir_elem| !matchEndPoints_arr.index(mir_elem.dst_endpoint).nil?  }
    match_mir_arr
  end # end def self.mir_from_find_match_dstEndPoints

  def self.mir_from_find_match_srcEndPoints(meantItRels, matchEndPoints_arr)
    match_mir_arr = meantItRels.find_all { |mir_elem| !matchEndPoints_arr.index(mir_elem.src_endpoint).nil?  }
    match_mir_arr
  end # def self.mir_from_find_match_srcEndPoints

  SAY_ENUM = ["said", "quipped", "uttered", "hollered", "mentioned", "mumbled"]
  def self.random_say
    SAY_ENUM[rand(SAY_ENUM.size)]
  end # def self.random_say

  def self.create_entity(login_name, password, logtag = nil)
    logtag = ControllerHelper.gen_logtag
    entity = Entity.new(:login_name => login_name, :password => password)
    # If login_name is email then create propertyDocument/entityDatum
    email_hash = ControllerHelper.parse_email(login_name)
    name = email_hash[ControllerHelper::EMAIL_NICK_STR]
    email = email_hash[ControllerHelper::EMAIL_STR]
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create_entity:#{logtag}, name:#{name}, email:#{email}")
    new_person = ControllerHelper.find_or_create_person_by_email(name, email) if !email.nil?
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create_entity:#{logtag}, new_person.inspect:#{new_person.inspect}")
    entity.property_document_id = new_person.id if !new_person.nil?
    entity.save
    entity
  end # end def self.createEntity

  def self.get_sender_endPoint_from_endPoints(endPoints)
    logtag = ControllerHelper.gen_logtag
    sender_endPoint = nil
    sender_endPoints = endPoints.select { |elem| elem.creator_endpoint_id == elem.id }
    if !sender_endPoints.nil?
      sender_endPoint = sender_endPoints[0]
      if sender_endPoints.size > 1
        Rails.logger.warn("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_sender_endPoint_from_endPoints:#{logtag}, sender_endPoints > 1, sender_endPoints.inspect:#{sender_endPoints.inspect}")
      end # end if sender_endPoints_arr.size > 1
    end # end if endPoints.nil?
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_sender_endPoint_from_endPoints:#{logtag}, sender_endPoint:#{sender_endPoint}")
    sender_endPoint
  end # end def self.get_sender_endPoint_from_endPoints

  def self.find_sender_endPoint_and_pii(pii_value, pii_type, pii_hide=PiiHideTypeValidator::PII_HIDE_TRUE)
    logtag = ControllerHelper.gen_logtag
    sender_endPoint = nil
    pii = Pii.find_by_pii_value_and_pii_type_and_pii_hide(pii_value, pii_type, pii_hide)
    if pii.nil? or pii.errors.any?
      if !pii.nil?
        Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_sender_endPoint_and_pii:#{logtag}, pii.errors.inspect:#{pii.errors.inspect}")
      else
        Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_sender_endPoint_and_pii:#{logtag}, pii.nil? is true")
      end # end if !pii.nil?
    else
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_sender_endPoint_and_pii:#{logtag}, pii.inspect:#{pii.inspect}")
    end # end if pii.nil? or pii.errors.any?
    if !pii.nil?
      sender_endPoint = ControllerHelper.get_sender_endPoint_from_endPoints(pii.endPoints)
    end # end if pii.nil?
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_sender_endPoint_and_pii:#{logtag}, sender_endPoint.inspect:#{sender_endPoint.inspect}")
    sender_endPoint
  end # end def self.find_sender_endPoint_and_pii

  def self.find_or_create_sender_endPoint_and_pii(pii_value, pii_type, pii_hide=PiiHideTypeValidator::PII_HIDE_TRUE)
    logtag = ControllerHelper.gen_logtag
#    pii = Pii.find_or_create_by_pii_value_and_pii_type_and_pii_hide(pii_value, pii_type, PiiHideTypeValidator::PII_HIDE_TRUE)
#20111026WTF    pii = Pii.find_or_create_by_pii_value_and_pii_type_and_pii_hide(:pii_value => pii_value, :pii_type => pii_type, :pii_hide => pii_hide)
    pii = Pii.find_or_create_by_pii_value_and_pii_type_and_pii_hide(pii_value, pii_type, PiiHideTypeValidator::PII_HIDE_TRUE)
    if pii.nil? or pii.errors.any?
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_sender_endPoint_and_pii:#{logtag}, pii.errors.inspect:#{pii.errors.inspect}")
    else
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_sender_endPoint_and_pii:#{logtag}, pii.inspect:#{pii.inspect}")
    end # end if pii.nil? or pii.errors.any?
    if !pii.nil?
      sender_endPoint = ControllerHelper.get_sender_endPoint_from_endPoints(pii.endPoints)
      if sender_endPoint.nil?
        sender_endPoint = pii.endPoints.create(:start_time => Time.now)
        sender_endPoint.pii = pii
        sender_endPoint.creator_endpoint_id = sender_endPoint.id
        unless sender_endPoint.save
          Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_sender_endPoint_and_pii:#{logtag}, sender_endPoint.errors.inspect:#{sender_endPoint.errors.inspect}")
        end # end unless sender_endPoint.save
      end # end # end if sender_endPoint.nil?
    end # end if pii.nil?
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_sender_endPoint_and_pii:#{logtag}, sender_endPoint.inspect:#{sender_endPoint.inspect}")
    sender_endPoint
  end # end def self.find_or_create_sender_endPoint_and_pii

#ABC  def self.set_options(options, option_key_sym, table_name_sym, table_col_sym, value, logtag = nil)
#ABC    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:set_options:#{logtag}, options[option_key_sym].class:#{options[option_key_sym].class}, options[option_key_sym].inspect:#{options[option_key_sym].inspect}")
#ABC    if options[option_key_sym].nil?
#ABC      options[option_key_sym] = { table_name_sym => { table_col_sym => value } }
#ABC    else
#ABC      if options[option_key_sym][table_name_sym].nil?
#ABC        options[option_key_sym] = { table_name_sym => { table_col_sym => value } }
#ABC      else
#ABC        options[option_key_sym][table_name_sym][table_col_sym] = value
#ABC      end # end if options[option_key_sym][table_name_sym].nil?
#ABC    end # end if options[table_name].nil?
#ABC  end # end def self.set_options

#ABC  def self.set_options_str(options, option_key_sym, opt_str, logtag = nil)
#ABC    if !opt_str.nil? and !opt_str.empty?
#ABC      if options[option_key_sym].nil?
#ABC        options[option_key_sym] = [opt_str]
#ABC      else
#ABC        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:set_options_str:#{logtag}, options[option_key_sym].class:#{options[option_key_sym].class}, options[option_key_sym].inspect:#{options[option_key_sym].inspect}")
#ABC        if options[option_key_sym].is_a?(Hash)
#ABC          opt_hash = options[option_key_sym]
#ABC          options[option_key_sym] = [opt_str, opt_hash]
#ABC        elsif options[option_key_sym].is_a?(Array)
#ABC          options[option_key_sym].unshift(opt_str)
#ABC        end # end if options[option_key_sym].is_a?(Hash)
#ABC      end # end if options[option_key_sym].nil?
#ABC    end # end if !opt_str.nil? ...
#ABC  end # end def self.set_options_str

  def self.find_like_pii_value_uniq_sender_count_after_last_bill(pii_value, logtag = nil)
    pii_virtual = nil
    after_date = nil
    if !pii_value.nil? and !pii_value.empty?
      desired_piis = Pii.joins("JOIN end_points on piis.id = end_points.pii_id").joins("JOIN meant_it_rels on meant_it_rels.dst_endpoint_id = end_points.id").where(:meant_it_rels => { :message_type => MeantItMessageTypeValidator::MEANT_IT_MESSAGE_LIKE}).where(:piis => { :pii_value => pii_value }).select("piis.pii_value, piis.status, piis.pii_hide, count(distinct meant_it_rels.src_endpoint_id) as mir_count").group("piis.pii_value, piis.status, piis.pii_hide")
      # Get the last bill date
      pii = Pii.find_by_pii_value(pii_value)
#20110813      if !pii.pii_property_set.nil? and !pii.pii_property_set.email_bill_entries.empty?
      if !pii.pii_property_set.nil?
#20110806a        email_bill_entries = pii.pii_property_set.email_bill_entries.sort { |elem1, elem2|
#20110806a          elem2.created_at <=> elem1.created_at
#20110806a        } # end email_bill_entries.sort
#20110806a        after_date = email_bill_entries[0].created_at
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pii.pii_property_set.inspect:#{pii.pii_property_set.inspect}")
        if pii.pii_property_set.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
          after_date = pii.pii_property_set.active_date
        elsif pii.pii_property_set.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_RECUR
          after_date_obj = pii.pii_property_set.last_bill("ready_date")
          if !after_date_obj.nil?
            after_date = after_date_obj.ready_date
          else
            # No billing etc., yet so use current date
            after_date = pii.pii_property_set.active_date
          end # end if !after_date_obj.nil?
        else
           Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pps.threshold_type:#{pps.threshold_type} not supported by billing system")
          raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pps.threshold_type:#{pps.threshold_type} not supported by billing system"
        end # end if pps.threshold_type
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, after_date:#{after_date}")
        after_date = ControllerHelper.validate_date(after_date.to_s)
        pii_virtual = nil
        if !after_date.nil?
          pii_virtual = desired_piis.where("meant_it_rels.created_at >= '#{after_date}' and meant_it_rels.email_bill_entry_id is NULL")
        else
          pii_virtual = desired_piis.where("meant_it_rels.email_bill_entry_id is NULL")
        end # end if !after_date.nil?
      end # end if !pii.pii_property_set.nil? ...
#DEBUG      ControllerHelper.set_options_str(options, :conditions, "meant_it_rels.created_at > '2011-08-05 11:12:20'") if after_date.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pii_virtual.inspect:#{pii_virtual.inspect}")
      # We expect only one
      pii_virtual.each { |pii_elem|
        class << pii_elem
          attr_accessor :after_date
        end
        pii_elem.after_date = after_date
      } # end pii_virtual.each ...
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pii_virtual.inspect:#{pii_virtual.inspect}")
    end # end if !pii_value.nil? and !pii_value.empty?
    pii_virtual
  end # end def self.find_like_pii_value_uniq_sender_count_after_last_bill

  def self.find_pii_by_message_type_uniq_sender_count(pii_value, message_type, limit = nil, order = nil, logtag = nil)
    limit = ControllerHelper.validate_number(limit, Constants::LIKEBOARD_REC_LIMIT)
    order = ControllerHelper.sql_validate_order(order, Constants::SQL_COUNT_ORDER_DESC)
# NOT DISTINCT src_endpoint_id so WRONG!!!
#    options = { :select => "piis.pii_value, piis.status, piis.pii_hide, count(*) as mir_count", :joins => ["JOIN end_points on piis.id = end_points.pii_id",  "JOIN meant_it_rels on meant_it_rels.dst_endpoint_id = end_points.id"], :group => "piis.pii_value, piis.status, piis.pii_hide", :limit => limit, :order => "mir_count #{order}" }
    desired_piis = Pii.select("piis.pii_value, piis.status, piis.pii_hide, count(distinct meant_it_rels.src_endpoint_id) as mir_count").joins("JOIN end_points on piis.id = end_points.pii_id").joins("JOIN meant_it_rels on meant_it_rels.dst_endpoint_id = end_points.id").group("piis.pii_value, piis.status, piis.pii_hide").limit(limit).order("mir_count #{order}")
    if !message_type.nil? and !message_type.empty?
      normalized_msg_type_downcase = MessageTypeMapper.get_message_type(message_type.downcase)
      desired_piis = desired_piis.where(:meant_it_rels => { :message_type => normalized_msg_type_downcase })
    end # end if !message_type.nil? and !message_type.empty?
    if !pii_value.nil? and !pii_value.empty?
      desired_piis = desired_piis.where(:piis => { :pii_value => pii_value})
    end # end if !pii_value.nil? and !pii_value.empty?
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_pii_by_message_type_uniq_sender_count:#{logtag}, desired_piis.inspect:#{desired_piis.inspect}")
    desired_piis
  end # end def self.find_pii_by_message_type_uniq_sender_count

  def self.validate_date(datetime_str, datetime_output_format_str = '%Y-%m-%d %H:%M:%S', logtag = nil)
    date_obj = DateTime.parse(datetime_str)
    date_obj.strftime(datetime_output_format_str)
  end # end def self.validate_date

  def self.get_meant_it_rels_by_pii_value_message_type_within_dates(pii_value, message_type, start_date, end_date, non_bill = true, logtag = nil)
    mirs = nil
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_meant_it_rels_by_pii_value_message_type_within_dates:#{logtag}, pii_value:#{pii_value}, message_type:#{message_type}, start_date:#{start_date}, end_date:#{end_date}")
    if start_date.nil? or start_date.empty?
      validated_start_date = nil
    elsif start_date.is_a?(String)
      validated_start_date = ControllerHelper.validate_date(start_date)
    elsif start_date.is_a?(Date)
      validated_start_date = ControllerHelper.validate_date(start_date.to_s)
    else
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_meant_it_rels_by_pii_value_message_type_within_dates:#{logtag}, start_date:#{start_date} is invalid.")
      raise ArgumentError, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_meant_it_rels_by_pii_value_message_type_within_dates:#{logtag}, start_date:#{start_date} is invalid."
    end # end if start_date.is_a?(String)
    if end_date.nil? or end_date.empty?
      validated_end_date = nil
    elsif end_date.is_a?(String)
      validated_end_date = ControllerHelper.validate_date(end_date)
    elsif end_date.is_a?(Date)
      validated_end_date = ControllerHelper.validate_date(end_date.to_s)
    else
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_meant_it_rels_by_pii_value_message_type_within_dates:#{logtag}, end_date:#{end_date} is invalid.")
      raise ArgumentError, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_meant_it_rels_by_pii_value_message_type_within_dates:#{logtag}, end_date:#{end_date} is invalid."
    end # end if end_date.is_a?(String)
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_meant_it_rels_by_pii_value_message_type_within_dates:#{logtag}, validated_start_date:#{validated_start_date}, validated_end_date:#{validated_end_date}")
    mirs = MeantItRel.select("meant_it_rels.status, meant_it_rels.src_endpoint_id").joins("JOIN end_points on meant_it_rels.dst_endpoint_id = end_points.id", "JOIN piis on end_points.pii_id = piis.id").group("meant_it_rels.src_endpoint_id, meant_it_rels.status")
    mirs = mirs.where(:meant_it_rels => { :message_type => message_type }) if !message_type.nil? and !message_type.empty?
    mirs = mirs.where(:piis => { :pii_value => pii_value }) if !pii_value.nil? and !pii_value.empty?
    option_str_all = ControllerHelper.get_date_option_str(validated_start_date, validated_end_date, true, logtag)
    if !option_str_all.nil?
       mirs = mirs.where(option_str_all)
    end # end if !option_str_all.nil?
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_meant_it_rels_by_pii_value_message_type_within_dates:#{logtag}, mirs.inspect:#{mirs.inspect}")
    mirs
  end # end def self.get_meant_it_rels_by_pii_value_message_type_within_dates

  def self.sort_by_created_at(entries)
    sorted_entries = entries.sort { |elem1, elem2|
      elem2.created_at <=> elem1.created_at
    } # end entries.sort
    sorted_entries
  end # end def self.sort_by_created_at

  # If email_bill_entry_id is nil then the likers after the last
  # billing will be returned
  # NOTE: likers returned are meant_it_rels
  # OBSOLETED since we can now retieve entries using email_bill_entries.mirs
  # OBSOLETED since we can now retieve latest entries 
  #           using get_latest_likers_by_pii_value
  def self.get_likers_by_email_bill_entry_id(pii_value, email_bill_entry_id = nil, logtag = nil)
    likers = nil
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_likers_by_email_bill_entry_id:#{logtag}, pii_value:#{pii_value}, email_bill_entry_id:#{email_bill_entry_id}")
    if !pii_value.nil? and !pii_value.empty? 
      pii = Pii.find_by_pii_value(pii_value)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_likers_by_email_bill_entry_id:#{logtag}, pii.inspect:#{pii.inspect}")
      pii_sender_endPoint = ControllerHelper.get_sender_endPoint_from_endPoints(pii.endPoints)
      entity_no_match_arr = pii_value.match(/(\d+)#{Constants::ENTITY_DOMAIN_MARKER}/)
      entity_no = entity_no_match_arr[1] if !entity_no_match_arr.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_likers_by_email_bill_entry_id:#{logtag}, entity_no:#{entity_no}")
      entity = Entity.find(entity_no)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_likers_by_email_bill_entry_id:#{logtag}, entity.inspect:#{entity.inspect}")
      bill_obj = nil
      start_bill_date = nil
      end_bill_date = nil
      if !pii.nil? and !pii.pii_property_set.nil?
        if email_bill_entry_id.nil? or email_bill_entry_id.empty?
          bill_obj = pii.pii_property_set.last_bill("billed_date")
          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_likers_by_email_bill_entry_id:#{logtag}, email_bill_entry_id is nil or empty, set start_bill.inspect:#{start_bill.inspect}")
          if !bill_obj.nil?
            start_bill_date = bill_obj.ready_date
          end # end if !bill_obj.nil?
          likers = ControllerHelper.get_meant_it_rels_by_pii_value_message_type_within_dates(pii_value, MeantItMessageTypeValidator::MEANT_IT_MESSAGE_LIKE, start_bill_date.to_s, end_bill_date.to_s, true, logtag)
#20110813          start_bill_date = pii.pii_property_set.last_bill_by_ready_date
#20110813          end_bill_date = nil
#20110813          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_likers_by_email_bill_entry_id:#{logtag}, email_bill_entry_id is nil or empty, set start_bill_date.inspect:#{start_bill_date.inspect}, end_bill_date.inspect:#{end_bill_date.inspect}")
        elsif !entity.nil? and !entity.email_bill.nil? and !entity.email_bill.email_bill_entries.nil? and !entity.email_bill.email_bill_entries.empty?
          bill_obj = pii.pii_property_set.email_bill_entries.find { |bill_elem|
            bill_elem.id == email_bill_entry_id
          } # end pii.pii_property_set.email_bill_entries.each ...
          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_likers_by_email_bill_entry_id:#{logtag}, email_bill_entry_id:#{email_bill_entry_id} , set start_bill.inspect:#{start_bill.inspect}")
          likers = bill_obj.mirs
#20110813          sorted_bill_entries = ControllerHelper.sort_by_created_at(entity.email_bill.email_bill_entries)
#20110813          next_idx = nil
#20110813          sorted_bill_entries.each_with_index { |bill_entry_elem, idx|
#20110813             if bill_entry_elem.id = email_bill_entry_id
#20110813               start_bill_date = bill_entry_elem.created_at
#20110813               next_idx = idx + 1
#20110813               break
#20110813             end # end if bill_entry_elem.id = email_bill_entry_id
#20110813          }
#20110813          if start_bill_date.nil?
#20110813            Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_likers_by_email_bill_entry_id:#{logtag}, no such email_bill_entry_id:#{email_bill_entry_id}")
#20110813            raise ArugmentError, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_likers_by_email_bill_entry_id:#{logtag}, no such email_bill_entry_id:#{email_bill_entry_id}"
#20110813          end # end if start_bill_date.nil?
#20110813          if !next_idx.nil? and next_idx < sorted_bill_entries.size
#20110813            end_bill_date = sorted_bill_entries[next_idx].created_at
#20110813          end # end if !next_idx.nil? and next_idx < sorted_bill_entries.size
#20110813          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_likers_by_email_bill_entry_id:#{logtag}, email_bill_entry_id is not nil nor empty, set start_bill_date.inspect:#{start_bill_date.inspect}, end_bill_date.inspect:#{end_bill_date.inspect}")
        end # end if bill_id.nil? or bill_id.empty?
      end # end if !pii.nil? and !pii.pii_property_set.nil?
    end # end if !pii_value and !pii_value.empty? 
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_likers_by_email_bill_entry_id:#{logtag}, likers.inspect:#{likers.inspect}")
    likers
  end # end def self.get_likers_by_bill_id

  def self.gen_contract_no(pii_value, liker_endpoint, logtag = nil)
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:gen_contract_no:#{logtag}, pii_value:#{pii_value}, liker_endpoint.inspect:#{liker_endpoint.inspect}")
    liker_endpoint_id = liker_endpoint.id
    entity_no_match_arr = pii_value.match(/(\d+)#{Constants::ENTITY_DOMAIN_MARKER}/)
    entity_no = entity_no_match_arr[1] if !entity_no_match_arr.nil?
    entity = Entity.find(entity_no)
    if entity.nil?
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:gen_contract_no:#{logtag}, no entity found for pii_value:#{pii_value}")
      raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:gen_contract_no:#{logtag}, no entity found for pii_value:#{pii_value}"
    end # end if entity.nil?
    salt = entity.password_salt
    combo_str = pii_value.to_s+liker_endpoint_id.to_s
    contract_no = BCrypt::Engine.hash_secret(combo_str, salt)  
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:gen_contract_no:#{logtag}, pii_value:#{pii_value}, liker_endpoint_id:#{liker_endpoint_id}, contract_no:#{contract_no}")
    contract_no
  end # end def self.gen_contract_no(pii_value, mir)

  def self.get_latest_likers_by_pii_value(pii_value, logtag = nil)
    likers = nil
    start_bill_date = nil
    end_bill_date = nil
    pii = Pii.find_by_pii_value(pii_value)
    if !pii.nil?
      pps = pii.pii_property_set
      if !pps.nil?
         if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
           start_bill_date = pps.active_date
         elsif pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_RECUR
           start_bill = pps.last_bill("ready_date")
           if !start_bill.nil?
             start_bill_date = start_bill.ready_date
           else
             # No billing etc., yet so use current date
             start_bill_date = pii.pii_property_set.active_date
           end # end if !after_date_obj.nil?
         else
            Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_latest_likers_by_pii_value:#{logtag}, pps.threshold_type:#{pps.threshold_type} not supported by billing system")
           raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_latest_likers_by_pii_value:#{logtag}, pps.threshold_type:#{pps.threshold_type} not supported by billing system"
         end # end if pps.threshold_type
         likers = ControllerHelper.get_meant_it_rels_by_pii_value_message_type_within_dates(pii_value, MeantItMessageTypeValidator::MEANT_IT_MESSAGE_LIKE, start_bill_date.to_s, end_bill_date.to_s, true, logtag)
      else 
        Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_latest_likers_by_pii_value:#{logtag}, pii_value:#{pii_value} has no pii_property_set")
        raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_latest_likers_by_pii_value:#{logtag}, pii_value:#{pii_value} has no pii_property_set"
      end # end if !pps.nil?
    else
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_latest_likers_by_pii_value:#{logtag}, no such Pii for pii_value:#{pii_value}")
      raise ArgumentError, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_latest_likers_by_pii_value:#{logtag}, no such Pii for pii_value:#{pii_value}"
    end # end if !pii.nil? and !pii.empty?
    return likers, start_bill_date, end_bill_date
  end # end def self.get_latest_likers_bypii_value(pii_value)

  def self.get_date_option_str(start_date, end_date, non_bill = true, logtag = nil)
    option_str_all = nil
    non_bill_str = "meant_it_rels.email_bill_entry_id is NULL" if non_bill
    validated_start_date_str = "meant_it_rels.created_at >= '#{start_date}'" if !start_date.nil?
    validated_end_date_str = "meant_it_rels.created_at <= '#{end_date}'" if !end_date.nil?
    option_str_arr = [validated_start_date_str, validated_end_date_str, non_bill_str]
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_date_option_str:#{logtag}, option_str_arr.inspect:#{option_str_arr.inspect}")
    option_str_all_arr = option_str_arr.find_all { |opt_elem| !opt_elem.nil? }
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_date_option_str:#{logtag}, option_str_all_arr.inspect:#{option_str_all_arr.inspect}")
    if !option_str_all_arr.empty?
      option_str_all = option_str_all_arr.join(" and ")
    end # end if option_str_all_arr.empty?
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_date_option_str:#{logtag}, option_str_all:#{option_str_all}")
    option_str_all
  end # end def self.get_date_option_str

  def self.is_similar?(word1, word2, acceptable_diff_set=['_', ' ', '-'].to_set, logtag=nil)
    similar = false
    if !word1.nil? and !word2.nil? and word1.size == word2.size
      diff_found_set = Set.new
      word1.size.times { |idx|
        if word1[idx,1] != word2[idx,1]
          diff_found_set.add(word1[idx,1])
          diff_found_set.add(word2[idx,1])
        end # end if word1[idx,1] != word2[idx,1]
      } # end word1.size.times ...
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:is_similar?:#{logtag}, word1:#{word1}, word2:#{word2}, acceptable_diff_set.inspect:#{acceptable_diff_set.inspect}, diff_found_set.inspect:#{diff_found_set.inspect}")
      if diff_found_set.subset? acceptable_diff_set
        similar = true
      end # end if diff_found_set.subset? acceptable_diff_set
    end # end if !word1.nil? and !word2.nil? and word1.size == word2.size
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:is_similar?:#{logtag}, word1:#{word1}, word2:#{word2}, similar:#{similar}")
    similar
  end # end def self.is_similar?

  #  AI:PII#1: if we show pii: 
  #    - AI:PII#1a) show short_desc if it is similar to pii, we don't want ppl to fake
  #      pii, e.g., :gloomy but short_desc = 'hello kitty'
  #    - AI:PII#1b) if pii_value is NUM+ENTITY_DOMAIN_MARKER+pii 
  #                 and NUM has nick, display NUM nick's short_desc 
  #                 or NUM nick's pii
  #    - AI:PII#1c) if pii_value is NUM+ENTITY_DOMAIN_MARKER+pii 
  #                 and NUM has no nick, display 'entity NUM's short_desc'
  #                 or 'entity NUM's pii'
  #    - AI:PII#1d) else just show pii
  def self.ai_for_pii(pii, logtag=nil)
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:ai_for_pii:#{logtag}, pii.inspect:#{pii.inspect}")
    pii_orig_str = pii.pii_value
    # AI:PII#1d
    pii_display_str = "#{pii_orig_str}"
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:ai_for_pii:#{logtag}, AI:PII#1d (default) pii_display_str:#{pii_display_str}")
    pii_pps_short_desc = pii.pii_property_set.short_desc if !pii.pii_property_set.nil?
    if ControllerHelper.is_similar?(pii_orig_str, pii_pps_short_desc)
      # AI:PII#1a Check if there is short description and it must 
      # be similar otherwise we don't use short_desc
      pii_display_str = pii_pps_short_desc
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:ai_for_pii:#{logtag}, AI:PII#1a (default) pii_display_str:#{pii_display_str}")
    else
      # Check if PII has ENTITY_DOMAIN_MARKER
      pii_orig_str_match_arr = pii_orig_str.match(/(\d+)#{Constants::ENTITY_DOMAIN_MARKER}(.*)/)
      if !pii_orig_str_match_arr.nil?
        entity_id = pii_orig_str_match_arr[1]
        object_pii = pii_orig_str_match_arr[2]
        entity = Entity.find(entity_id)
        entity_datum = EntityDatum.find_by_id(entity.property_document_id)
        # Check if there nick for entity, if not then use entity id
        if !entity_datum.nil? and !entity_datum.nick.nil?
          # AI:PII#1b
          pii_display_str = "#{entity_datum.nick}'s #{object_pii}"
          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:ai_for_pii:#{logtag}, AI:PII#1b (default) pii_display_str:#{pii_display_str}")
        else
          # AI:PII#1c
          pii_display_str = "entity_#{entity_id}'s #{object_pii}"
          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:ai_for_pii:#{logtag}, AI:PII#1c (default) pii_display_str:#{pii_display_str}")
        end # end if entity_datum.nil? and entity_datum.nick.nil?
      end # end if !pii_orig_str_match_arr.nil?
    end # end if ControllerHelper.is_similar?(pii_orig_str, pii_pps_short_desc)
    pii_display_str
  end # end def self.ai_for_pii

  # Display nick_<endpoint_id> if it has no nick and no pii 
  # with pii_property_set or the pii_property_set.short_desc is empty/nil
  def self.ai_for_endpoint(ep, prefix, logtag=nil)
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:ai_for_endpoint:#{logtag}, ep.inspect:#{ep.inspect}")
    ep_display_str = "#{prefix}#{ep.id}"
    if !ep.pii.nil? and !ep.pii.pii_property_set.nil? and !ep.pii.pii_property_set.short_desc.nil? and !ep.pii.pii_property_set.short_desc.empty?
      ep_display_str = "\"#{ep.pii.pii_property_set.short_desc}\""
    end # end if !ep.pii.nil? and !ep.pii.pii_property_set.nil? and ...
    ep_display_str
  end # end def self.ai_for_endpoint
end # end module ControllerHelper
