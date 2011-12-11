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

  def self.find_person_by_email(email, logtag=nil)
    person = nil
    begin
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_person_by_email:#{logtag}, email:#{email}")
      person = Person.find_by_email(email)
    rescue Exception => e
    end # end cannot find person from couchdb
    if person.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_person_by_email:#{logtag}, person find triggered exception, e.inspect:#{e.inspect}")
      # Use sql instead of couchdb
      person = EntityDatum.find_by_email(:email => email)
#20111111      person = EntityDatum.find_by_email(email)
    end # end if person.nil?
    person
  end # end def self.find_person_by_email

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
      new_person = EntityDatum.find_or_create_by_email(:email => email)
#20111111      new_person = EntityDatum.find_or_create_by_email(email)
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
    pii_cond = "found"
    pii = Pii.find_or_create_by_pii_value_and_pii_type_and_pii_hide(:pii_value => pii_value, :pii_type => pii_type, :pii_hide => pii_hide) do |pii_obj|
      pii_cond = "created"
    end # end Pii.find_or_create_by_pii_value ...
#2011111WTF    pii = Pii.find_or_create_by_pii_value_and_pii_type_and_pii_hide(pii_value, pii_type, PiiHideTypeValidator::PII_HIDE_TRUE)
    if pii.nil? or pii.errors.any?
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_sender_endPoint_and_pii:#{logtag}, pii.errors.inspect:#{pii.errors.inspect}")
    else
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_sender_endPoint_and_pii:#{logtag}, pii.inspect:#{pii.inspect}")
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_sender_endPoint_and_pii:#{logtag}, #{pii_cond} pii, pii_value:#{pii.pii_value}")
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
        Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_sender_endPoint_and_pii:#{logtag}, created sender_endPoint, sender_endPoint.inspect:#{sender_endPoint.inspect}")
      else
        Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_or_create_sender_endPoint_and_pii:#{logtag}, found sender_endPoint, sender_endPoint.inspect:#{sender_endPoint.inspect}")
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

  # +return+ +Pii+ array, after_date
  # NOTE: after_date is when deal was started which is calculated
  # by considering threshold_type (ONE_TIME, RECUR)
  def self.find_like_pii_value_uniq_sender_count_after_last_bill(pii_value, logtag = nil)
    pii_virtual = nil
    after_date = nil
    if !pii_value.nil? and !pii_value.empty?
      desired_piis = Pii.joins("JOIN end_points on piis.id = end_points.pii_id").joins("JOIN meant_it_rels on meant_it_rels.dst_endpoint_id = end_points.id").where(:meant_it_rels => { :message_type => MeantItMessageTypeValidator::MEANT_IT_MESSAGE_LIKE}).where(:piis => { :pii_value => pii_value }).select("piis.pii_value, piis.status, piis.pii_hide, count(distinct meant_it_rels.src_endpoint_id) as mir_count").group("piis.pii_value, piis.status, piis.pii_hide")
      # Get the last bill date
      after_date = self.get_bill_dates_by_pii_value(pii_value)
#YYYY      pii = Pii.find_by_pii_value(pii_value)
#20110813      if !pii.pii_property_set.nil? and !pii.pii_property_set.email_bill_entries.empty?
#YYYY      if !pii.pii_property_set.nil?
#20110806a        email_bill_entries = pii.pii_property_set.email_bill_entries.sort { |elem1, elem2|
#20110806a          elem2.created_at <=> elem1.created_at
#20110806a        } # end email_bill_entries.sort
#20110806a        after_date = email_bill_entries[0].created_at
#YYYY        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pii.pii_property_set.inspect:#{pii.pii_property_set.inspect}")
#YYYY        if pii.pii_property_set.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
#YYYY          after_date = pii.pii_property_set.active_date
#YYYY        elsif pii.pii_property_set.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_RECUR
#YYYY          after_date_obj = pii.pii_property_set.last_bill("ready_date")
#YYYY          if !after_date_obj.nil?
#YYYY            after_date = after_date_obj.ready_date
#YYYY          else
#YYYY            # No billing etc., yet so use current date
#YYYY            after_date = pii.pii_property_set.active_date
#YYYY          end # end if !after_date_obj.nil?
#YYYY        else
#YYYY           Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pps.threshold_type:#{pps.threshold_type} not supported by billing system")
#YYYY          raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pps.threshold_type:#{pps.threshold_type} not supported by billing system"
#YYYY        end # end if pps.threshold_type
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, after_date:#{after_date}")
        after_date = ControllerHelper.validate_date(after_date.to_s)
        pii_virtual = nil
        if !after_date.nil?
          pii_virtual = desired_piis.where("meant_it_rels.created_at >= '#{after_date}' and meant_it_rels.email_bill_entry_id is NULL")
        else
          pii_virtual = desired_piis.where("meant_it_rels.email_bill_entry_id is NULL")
        end # end if !after_date.nil?
#YYYY      end # end if !pii.pii_property_set.nil? ...
#DEBUG      ControllerHelper.set_options_str(options, :conditions, "meant_it_rels.created_at > '2011-08-05 11:12:20'") if after_date.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pii_virtual.inspect:#{pii_virtual.inspect}")
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, setting pii_virtual with after_date.inspect:#{after_date.inspect}")
      # We expect only one
      pii_virtual.each { |pii_elem|
        class << pii_elem
          attr_accessor :after_date
        end
        pii_elem.after_date = after_date
      } # end pii_virtual.each ...
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:find_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pii_virtual.inspect:#{pii_virtual.inspect}")
    end # end if !pii_value.nil? and !pii_value.empty?
    [pii_virtual, after_date]
  end # end def self.find_like_pii_value_uniq_sender_count_after_last_bill

  # This methods is used by group.html 'cos it takes additional steps
  # to populate the pii when it's inactive, nil, etc.
  # NOTE: This was migrated from piis_controller.rb's
  # +show_like_pii_value_uniq_sender_count_after_last_bill+
  # +return+ JSON
  def self.get_json_like_pii_value_uniq_sender_count_after_last_bill(pii_value, logtag=nil)
    piis, after_date = self.find_like_pii_value_uniq_sender_count_after_last_bill(pii_value, logtag)
    self.add_virtual_methods_to_pii(piis[0], pii_value)
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:get_json_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, piis.inspect:#{piis.inspect}")
    if piis.nil? or piis.empty?
      pii = Pii.find_by_pii_value(pii_value)
      pps = pii.pii_property_set
      made_mir_count = nil
      if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME and pps.status == StatusTypeValidator::STATUS_INACTIVE
        made_mir_count = pps.threshold
      else
        made_mir_count = 0
      end # end if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
      made_pii = [:pii => { :pii_value => pii_value, :threshold => pps.threshold, :formula => pps.formula, :short_desc_data => pps.short_desc, :mir_count => made_mir_count, :thumbnail_url_data => pps.avatar.url(:thumb), :thumbnail_qr_data => pps.qr.url(:thumb), :threshold_type => pps.threshold_type, :after_date => after_date, :price => self.get_price_from_formula(pps.formula), :currency => self.get_currency_from_formula(pps.formula), :threshold_currency => pps.currency }]
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:get_json_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, made_pii.inspect:#{made_pii.inspect}")
      pii_to_json = made_pii.to_json
    else
      pii_to_json = piis.to_json(:methods => [:threshold, :formula, :short_desc_data, :long_desc_data, :thumbnail_url_data, :thumbnail_qr_data, :threshold_type, :after_date, :price, :currency, :threshold_currency ])
    end # end if piis.nil? or piis.empty?
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:get_json_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pii_to_json:#{pii_to_json}")
    pii_to_json
  end # end def self.get_json_like_pii_value_uniq_sender_count_after_last_bill

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

#20111106  def self.get_meant_it_rels_by_pii_value_message_type_within_dates(pii_value, message_type, start_date, end_date, status=StatusTypeValidator::STATUS_ACTIVE, non_bill=true, logtag=nil)
  def self.get_meant_it_rels_by_pii_value_message_type_within_dates(pii_value, message_type, start_date, end_date, status=StatusTypeValidator::STATUS_ACTIVE, uniq=true, non_bill=true, logtag=nil)
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
    if uniq
      mirs = MeantItRel.select("meant_it_rels.status, meant_it_rels.src_endpoint_id").joins("JOIN end_points on meant_it_rels.dst_endpoint_id = end_points.id", "JOIN piis on end_points.pii_id = piis.id").group("meant_it_rels.src_endpoint_id, meant_it_rels.status")
    else
      mirs = MeantItRel.select("meant_it_rels.status, meant_it_rels.src_endpoint_id").joins("JOIN end_points on meant_it_rels.dst_endpoint_id = end_points.id", "JOIN piis on end_points.pii_id = piis.id")
    end # end if uniq
    mirs = mirs.where(:status => status)
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

  # Contract (payment) is tied to and meant_it_rel.id
  # NOTE: we do not want to corrupt
  # mir by adding a field for contract no./payment id, etc since
  # it already has association with email_bill_entry.id
  # From mir, we can get email_bill_entry.
  # We can also get dest_pii, src_ep, entity of pii 
  # thus entity'salt to verify contract no.
#20111106  def self.gen_contract_no(pii_value, liker_endpoint, logtag = nil)
  def self.gen_contract_no(pii_value, mir_elem, logtag = nil)
    liker_endpoint = mir_elem.src_endpoint
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
#20111106    contract_no = BCrypt::Engine.hash_secret(combo_str, salt)
    contract_no = "#{mir_elem.id}#{Constants::CONTRACT_DELIM}#{Digest::SHA1.hexdigest(combo_str+salt)[Constants::SHA1_LEN-(Constants::CONTRACT_NO_LEN*2)..Constants::SHA1_LEN]}"
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:gen_contract_no:#{logtag}, pii_value:#{pii_value}, liker_endpoint_id:#{liker_endpoint_id}, contract_no:#{contract_no}")
    contract_no
  end # end def self.gen_contract_no(pii_value, mir)

  def self.verify_contract_no(contract_no)
    contract_no_match_arr = contract_no.match(/^(\d+)-/)
    fail_str = nil
    if !contract_no_match_arr.nil?
      fail_str = "Invalid contract_no:#{contract_no}, missing '-'"
    else
      mir_id = contract_no_match_arr[1]
      mir_elem = MeantItRel.find(mir_id)
      if mir_elem.nil?
       fail_str = "meant_it_rel:#{mir_id} does not exist"
      else
        # Get email_bill_entry
        ebe = mir_elem.email_bill_entry
        likee_pii_value = ebe.pii_property_set.pii.pii_value
        # Calculate contract number
        calc_contract_no = self.gen_contract_no(likee_pii_value, mir_elem)
        if calc_contract_no != contract_no
          fail_str = "invalid contract_no:#{contract_no}, failed checksum"
        end # end if calc_contract_no != contract_no
      end # end if mir_elem.nil?
    end # end if !contract_no_match_arr.nil?
    if !fail_str.nil?
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:verify_contract_no:#{logtag}, #{fail_str}")
      raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:verify_contract_no:#{logtag}, #{fail_str}"
    end # end if !fail_str.nil?
    return true
  end # end def self.verify_contract_no(contract_no)

  def self.get_bill_dates_by_pii_value(pii_value, logtag=nil)
    pii = Pii.find_by_pii_value(pii_value)
    start_bill_date = self.get_bill_dates_by_pii(pii)
    start_bill_date
  end # end def self.get_bill_dates_by_pii_value

  def self.get_bill_dates_by_pii(pii, logtag=nil)
    start_bill_date = nil
    if !pii.nil?
      pps = pii.pii_property_set
      if !pps.nil?
        if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
          start_bill_date = pps.active_date
          Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_bill_dates_by_pii:#{logtag}, pps.threshold_type:THRESHOLD_TYPE_ONETIME, start_bill_date.inspect:#{start_bill_date.inspect}")
        elsif pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_RECUR
          start_bill = pps.last_bill("ready_date")
#20111125          if !start_bill.nil?
          if !start_bill.nil? and !start_bill.ready_date.nil?
            start_bill_date = start_bill.ready_date
            Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_bill_dates_by_pii:#{logtag}, pps.threshold_type:THRESHOLD_TYPE_RECUR, start_bill.inspect:#{start_bill.inspect}")
          else
            # No billing etc., yet so use current date
            start_bill_date = pii.pii_property_set.active_date
            Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_bill_dates_by_pii:#{logtag}, pps.threshold_type:THRESHOLD_TYPE_RECUR, pps.active_date.inspect:#{pps.active_date.inspect}")
          end # end if !after_date_obj.nil?
        else
           Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_bill_dates_by_pii:#{logtag}, pps.threshold_type:#{pps.threshold_type} not supported by billing system")
          raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_bill_dates_by_pii:#{logtag}, pps.threshold_type:#{pps.threshold_type} not supported by billing system"
        end # end if pps.threshold_type
      else 
        Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_bill_dates_by_pii:#{logtag}, pii_value:#{pii_value} has no pii_property_set")
        raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_bill_dates_by_pii:#{logtag}, pii_value:#{pii_value} has no pii_property_set"
      end # end if !pps.nil?
    else
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_bill_dates_by_pii:#{logtag}, no such Pii for pii_value:#{pii_value}")
      raise ArgumentError, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_bill_dates_by_pii:#{logtag}, no such Pii for pii_value:#{pii_value}"
    end # end if !pii.nil? and !pii.empty?
    Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_bill_dates_by_pii:#{logtag}, start_bill_date.inspect:#{start_bill_date.inspect}")
    start_bill_date
  end # end def self.get_bill_dates_by_pii

  def self.get_latest_likers_by_pii_value(pii_value, status=StatusTypeValidator::STATUS_ACTIVE, uniq=true, logtag=nil)
    likers = nil
    start_bill_date = nil
    end_bill_date = nil
#XXXX    pii = Pii.find_by_pii_value(pii_value)
#XXXX    if !pii.nil?
#XXXX      pps = pii.pii_property_set
#XXXX      if !pps.nil?
#XXXX        if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
#XXXX           start_bill_date = pps.active_date
#XXXX         elsif pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_RECUR
#XXXX           start_bill = pps.last_bill("ready_date")
#XXXX           if !start_bill.nil?
#XXXX             start_bill_date = start_bill.ready_date
#XXXX           else
#XXXX             # No billing etc., yet so use current date
#XXXX             start_bill_date = pii.pii_property_set.active_date
#XXXX           end # end if !after_date_obj.nil?
#XXXX         else
#XXXX            Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_latest_likers_by_pii_value:#{logtag}, pps.threshold_type:#{pps.threshold_type} not supported by billing system")
#XXXX           raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_latest_likers_by_pii_value:#{logtag}, pps.threshold_type:#{pps.threshold_type} not supported by billing system"
#XXXX         end # end if pps.threshold_type
#XXXX         likers = ControllerHelper.get_meant_it_rels_by_pii_value_message_type_within_dates(pii_value, MeantItMessageTypeValidator::MEANT_IT_MESSAGE_LIKE, start_bill_date.to_s, end_bill_date.to_s, StatusTypeValidator::STATUS_ACTIVE, uniq, true, logtag)
#XXXX      else 
#XXXX        Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_latest_likers_by_pii_value:#{logtag}, pii_value:#{pii_value} has no pii_property_set")
#XXXX        raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_latest_likers_by_pii_value:#{logtag}, pii_value:#{pii_value} has no pii_property_set"
#XXXX      end # end if !pps.nil?
#XXXX    else
#XXXX      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_latest_likers_by_pii_value:#{logtag}, no such Pii for pii_value:#{pii_value}")
#XXXX      raise ArgumentError, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_latest_likers_by_pii_value:#{logtag}, no such Pii for pii_value:#{pii_value}"
#XXXX    end # end if !pii.nil? and !pii.empty?
    start_bill_date = self.get_bill_dates_by_pii_value(pii_value)
    likers = ControllerHelper.get_meant_it_rels_by_pii_value_message_type_within_dates(pii_value, MeantItMessageTypeValidator::MEANT_IT_MESSAGE_LIKE, start_bill_date.to_s, end_bill_date.to_s, StatusTypeValidator::STATUS_ACTIVE, uniq, true, logtag)
    return likers, start_bill_date, end_bill_date
  end # end def self.get_latest_likers_by_pii_value

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

  def self.order_endpoints
  end # end def self.order_endpoints

  def self.get_endpoint_price(ep, logtag=nil)
   price = nil
   if !ep.nil? and !ep.pii.nil?
     price = self.get_pii_price(ep.pii, logtag)
   end # end if !ep.nil? and !ep.pii.nil?
   price
  end # end def self.get_endpoint_price(pii, logtag=nil)

  def self.get_pii_price(pii, logtag=nil)
   price = nil
   if !pii.nil?
     if !pii.pii_property_set.nil?
       formula = pii.pii_property_set.formula
       price = self.get_price_from_formula(formula)
     end # end if !pii.pii_property_set.nil?
   end # end if !pii.nil?
   price
  end # end def self.get_pii_price

  def self.get_price_from_formula(formula)
    price = nil
    if !formula.nil? and !formula.empty?
      formula_match_arr = formula.match(/\d+/)
      price = formula_match_arr[0] if !formula_match_arr.nil?
    end # end if !formula.nil? and !formula.empty?
    price
  end # end def self.get_price_from_formula

  def self.get_currency_from_formula(formula)
    currency = Constants::DEFAULT_CURRENCY
    if !formula.nil? and !formula.empty?
      formula_match_arr = formula.match(/^[A-Za-z]+/)
      currency = formula_match_arr[0] if !formula_match_arr.nil?
    end # end if !formula.nil? and !formula.empty?
    currency
  end # end def self.get_currency_from_formula

  # Looks for +parm_name+ from formula string to get the value
  def self.get_named_parm_from_formula(formula, parm_name, default_val=nil, logtag=nil)
    val = default_val
    if !formula.nil? and !formula.empty?
      # We tried to use CGI.parse but there are issues since some
      # parm values are also cgi-like parms, e.g., 
      # parm1=http://shop.ccs.com/product/aaa?a=1&b=2&parm2=hello
      # Is confusing since within parm1 itself there are & and =
      formula_match_arr = formula.split(PiiPropertySet::DELIM)
      # Return first parm that matches parm_name
      formula_match_arr.each { |match_elem|
        parm_arr = match_elem.split('=')
        # Proper named parms have 2 elems, one on each side of '='
        if parm_arr.size == 2
          if parm_arr[0] == parm_name
            val = parm_arr[1]
            break
          end # end if parm_arr[0] == parm_name
        end # end if parm_arr.size == 2
      } # end formula_match_arr.each ...
    end # end if !formula.nil? and !formula.empty?
    val
  end # end def self.get_url_from_formula
  
  # +EndPoint+ may be sellable if it has pii that we can check
  # for sellability using +sellable_pii+
  # +:ep:+:: +EndPoint+ to check
  # +return+ boolean
  def self.sellable_endpoint(ep, logtag=nil)
    sellable = false
    if !ep.nil? and !ep.pii.nil?
      Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:sellable_endpoint:#{logtag}, ep.pii.inspect:#{ep.pii.inspect}")
      sellable = self.sellable_pii(ep.pii, logtag)
    end # end if !ep.nil? and !ep.pii.nil?
    sellable
  end # end def self.sellable_endpoint

  # Pii is sellable if it has +pii_property_set+
  # with +threshold+, +formula+ set and +status+ active
  # and +pii_value+ contains Constant::ENTITY_DOMAIN_MARKER
  # +:pii:+:: +Pii+ to check
  # +return+ boolean
  def self.sellable_pii(pii, logtag=nil)
    sellable = false
    if !pii.nil?
      pii_pps = pii.pii_property_set
      Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:sellable_pii:#{logtag}, pii_pps.inspect:#{pii_pps.inspect}")
      if pii.pii_value.match(/#{Constants::ENTITY_DOMAIN_MARKER}/) and !pii_pps.nil?
        # NOTE: we do not care about pii_price 'cos pii maybe to meet a
        # value, i.e., price is nil but there is a threshold
#20111112        if !pii_pps.threshold.nil? and !self.get_pii_price(pii).nil? and pii_pps.status == StatusTypeValidator::STATUS_ACTIVE
        if !pii_pps.threshold.nil? and !pii_pps.threshold_type.nil? and pii_pps.status == StatusTypeValidator::STATUS_ACTIVE and !pii_pps.value_type.nil?
          sellable = true
        end # end if !pii_pps.threshold.nil? and ...
      end # end if !pii_pps.nil?
    end # end if !pii.nil?
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:sellable_pii:#{logtag}, sellable:#{sellable}")
    sellable
  end # end def self.sellable_pii

  def self.add_virtual_methods_to_pii(pii_elem, pii_value)
    class << pii_elem
      def get_property_set_model
        pii_id = Pii.find_by_pii_value(pii_value)
        pii_property_set_model = PiiPropertySet.find_by_pii_id(pii_id)
        pii_property_set_model
      end

      def threshold
        @pii_property_set_model ||= get_property_set_model
        return_value = nil
        return_value = @pii_property_set_model.threshold if !@pii_property_set_model.nil?
        return_value
      end

      def threshold_currency
        @pii_property_set_model ||= get_property_set_model
        return_value = nil
        return_value = @pii_property_set_model.currency if !@pii_property_set_model.nil?
        return_value
      end

      def formula
        @pii_property_set_model ||= get_property_set_model
        return_value = nil
        return_value = @pii_property_set_model.formula if !@pii_property_set_model.nil?
        return_value
      end

      def price
        @pii_property_set_model ||= get_property_set_model
        return_value = nil
        formula = @pii_property_set_model.formula if !@pii_property_set_model.nil?
        return_value = ControllerHelper.get_price_from_formula(formula)
        return_value
      end # end def price

      def currency
        @pii_property_set_model ||= get_property_set_model
        return_value = nil
        formula = @pii_property_set_model.formula if !@pii_property_set_model.nil?
        return_value = ControllerHelper.get_currency_from_formula(formula)
        return_value
      end # end def currency

      def short_desc_data
        @pii_property_set_model ||= get_property_set_model
        return_value = nil
        return_value = @pii_property_set_model.short_desc if !@pii_property_set_model.nil?
        return_value
      end

      def long_desc_data
        @pii_property_set_model ||= get_property_set_model
        return_value = nil
        return_value = @pii_property_set_model.long_desc if !@pii_property_set_model.nil?
        return_value
      end

      def thumbnail_url_data
        @pii_property_set_model ||= get_property_set_model
        return_value = nil
        return_value = @pii_property_set_model.avatar.url(:thumb) if !@pii_property_set_model.nil?
        return_value
      end

      def thumbnail_qr_data
        @pii_property_set_model ||= get_property_set_model
        return_value = nil
        return_value = @pii_property_set_model.qr.url(:thumb) if !@pii_property_set_model.nil?
        return_value
      end

      def threshold_type
        @pii_property_set_model ||= get_property_set_model
        return_value = nil
        return_value = @pii_property_set_model.threshold_type if !@pii_property_set_model.nil?
        return_value
      end
    end # end class << pii_elem
  end # end def self.add_virtual_methods_to_pii

  def self.sort_pii_virtuals(pii_virtuals, sort_field=nil, sort_order=nil, logtag=nil)
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:sort_pii_virtuals:#{logtag}, pii_virtuals.inspect:#{pii_virtuals.inspect}")
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:sort_pii_virtuals:#{logtag}, sort_order:#{sort_order}, sort_field:#{sort_field}")
    if !ShopsController::SORT_ORDER_ENUM.include?(sort_order)
      sort_order = ShopsController::SORT_ORDER_DESC
    end # end if !ShopsController::SORT_ORDER_ENUM.include?(sort_order)
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:sort_pii_virtuals:#{logtag}, corrected sort_order:#{sort_order}")
    if ShopsController::SORT_FIELD_ENUM.include?(sort_field)
      if sort_field == ShopsController::SORT_FIELD_DATE and sort_order == ShopsController::SORT_ORDER_ASC
        Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:sort_pii_virtuals:#{logtag}, sort based on date and asc")
        sorted_pii_virtuals = pii_virtuals.sort { |a,b| a.after_date <=> b.after_date }
      elsif sort_field == ShopsController::SORT_FIELD_DATE and sort_order == ShopsController::SORT_ORDER_DESC
        Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:sort_pii_virtuals:#{logtag}, sort based on date and desc")
        sorted_pii_virtuals = pii_virtuals.sort { |a,b| b.after_date <=> a.after_date }
      elsif sort_field == ShopsController::SORT_FIELD_PRICE and sort_order == ShopsController::SORT_ORDER_ASC
        sorted_pii_virtuals = pii_virtuals.sort { |a,b| ControllerHelper.get_price_from_formula(a.formula).to_i <=> ControllerHelper.get_price_from_formula(b.formula).to_i }
      elsif sort_field == ShopsController::SORT_FIELD_PRICE and sort_order == ShopsController::SORT_ORDER_DESC
        sorted_pii_virtuals = pii_virtuals.sort { |a,b| ControllerHelper.get_price_from_formula(b.formula).to_i <=> ControllerHelper.get_price_from_formula(a.formula).to_i }
      elsif sort_field == ShopsController::SORT_FIELD_GROUP_SIZE and sort_order == ShopsController::SORT_ORDER_ASC
        sorted_pii_virtuals = pii_virtuals.sort { |a,b| a.threshold.to_i <=> b.threshold.to_i }
      elsif sort_field == ShopsController::SORT_FIELD_GROUP_SIZE and sort_order == ShopsController::SORT_ORDER_DESC
        sorted_pii_virtuals = pii_virtuals.sort { |a,b| b.threshold.to_i <=> a.threshold.to_i }
      elsif sort_field == ShopsController::SORT_FIELD_NEAR_GOAL and sort_order == ShopsController::SORT_ORDER_ASC
        sorted_pii_virtuals = pii_virtuals.sort { |a,b| a.mir_count.to_f/a.threshold.to_f <=> b.mir_count.to_f/b.threshold.to_f }
      elsif sort_field == ShopsController::SORT_FIELD_NEAR_GOAL and sort_order == ShopsController::SORT_ORDER_DESC
        sorted_pii_virtuals = pii_virtuals.sort { |a,b| b.mir_count.to_f/b.threshold.to_f <=> a.mir_count.to_f/a.threshold.to_f }
      end # end if ...
    else
      sorted_pii_virtuals = pii_virtuals
    end # end if ShopsController::SORT_FIELD_ENUM.include?(pii_virtuals)
    sorted_pii_virtuals
  end # end def self.sort_pii_virtuals

  
  def self.get_entity_no_from_pii(pii, logtag=nil)
    entity_no = nil
    if !pii.nil?
      self.get_entity_no_from_pii_value(pii.pii_value)
    end # end if !pii.nil?
    entity_no
  end # end def self.get_entity_no_from_pii

  def self.get_entity_no_from_pii_value(pii_value, logtag=nil)
    entity_no = nil
    if !pii_value.nil?
      entity_no_match_arr = pii_value.match(/(\d+)#{Constants::ENTITY_DOMAIN_MARKER}/)
      entity_no = entity_no_match_arr[1] if !entity_no_match_arr.nil?
    end # end if !pii_value.nil?
    entity_no
  end # end def self.get_entity_no_from_pii_value

  # Given a string extract all the currency within
  # Return +Array+ with currency with 3-digit code, nil if +str+ provided is nil
  def self.get_currency_arr_from_str(str, logtag=nil)
    currency_arr = nil
    if !str.nil?
      # Extract words with preceded by '$' or 3 letter codes
      currency_arr = str.scan(/#{Constants::CURREG1}#{Constants::CURREG2}/)
    end # end if !str.nil?
    currency_arr
  end # end def self.get_currency_arr_from_str

  def self.convert_currency(from_currency_val, to_currency, logtag=nil)
    from_currency = self.get_currency_code(from_currency_val)
    # Get the conversion rate table from somewhere
    Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:convert_currency:#{logtag}, no @rate_table_hash yet!")
    raise Exception, "no @rate_table_hash yet!"
    rate = @rate_table_hash[from_currency][to_currency]
    # For now we don't do conversion, we throw error
    new_currency = from_currency_vale*rate
    new_currency = to_currency + new_currency
    new_currency
  end # end def self.convert_currency

  # Given a currency, e.g., SGD300.00, returns the 3-digit
  # currency code
  # Return +String+
  def self.get_currency_code(currency, logtag=nil)
    currency_code = nil
    if currency.class == String
      currency_code_match = currency.match(/^#{Constants::CURREG1}/)
      currency_code = currency_code_match.to_s if !currency_code_match.nil?
    elsif currency.class == Integer or currency.class == Fixnum
      # It's ok just let currency_code be nil
    else
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_currency_code:#{logtag}, not a valid currency or number, currency:#{currency}, currency.class:#{currency.class} must be String, Fixnum or Integer")
      raise ArgumentError, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_currency_code:#{logtag}, not a valid currency or number, currency:#{currency}, currency.class:#{currency.class} must be String, Fixnum or Integer"
    end # end if currency.class == String
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_currency_code:#{logtag}, currency:#{currency}, currency_code:#{currency_code}")
    currency_code
  end # end def self.get_currency_code

  # Given a currency, e.g., SGD300.00, returns the 3-digit
  # currency code and value, i.e., SGD, and 300.00
  # Return +[String, Float]+
  def self.get_currency_code_and_val(currency, logtag=nil)
    curr_code = nil
    curr_val = nil
    if currency.class == Fixnum or currency.class == Integer or currency.class == Float
      curr_val = currency.to_f
    elsif currency.class == String
      currency_str = currency.strip
      currency_match_arr = currency_str.match(/^(#{Constants::CURREG1})(#{Constants::CURREG2})/)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_currency_code_and_val:#{logtag}, currency_match_arr.inspect:#{currency_match_arr.inspect}")
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_currency_code_and_val:#{logtag}, currency_match_arr.nil?:#{currency_match_arr.nil?}")
      if currency_match_arr.nil?
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_currency_code_and_val:#{logtag}, FUCKOFF!!!")
        currency_match_arr = currency.match(/^(#{Constants::CURREG2})/)
        if !currency_match_arr.nil?
          curr_val = currency_match_arr[1]
        else
          Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:currency_op:#{logtag}, not a valid currency or number, currency:#{currency}")
          raise ArgumentError, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:currency_op:#{logtag}, not a valid currency or number, currency:#{currency}"
        end # end if !currency_match_arr.nil?
      else
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_currency_code_and_val:#{logtag}, FUCKOFFF222!!!")
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_currency_code_and_val:#{logtag}, HERE, curr_code:#{curr_code}, curr_val:#{curr_val}")
        curr_code = currency_match_arr[1].to_s
        curr_val = currency_match_arr[2].to_f
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_currency_code_and_val:#{logtag}, HERE, curr_code:#{curr_code}, curr_val:#{curr_val}")
      end # end if currency_match_arr.nil?
    else
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:currency_op:#{logtag}, not a valid currency or number, currency:#{currency}, currency.class:#{currency.class} must be String, Fixnum, Integer")
    end # end if currency.class == Fixnum or currency.class == Integer
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:get_currency_code_and_val:#{logtag}, currency:#{currency}, curr_code:#{curr_code}, curr_val:#{curr_val}")
    [curr_code, curr_val]
  end # end def self.get_currency_code_and_val

  # +:arr:+:: arr containing all the currency values preceded by 3-digit code
  # +:base_curr:+:: the final result of all currency operations. Defaults to Constants::DEFAULT_CURRENCY
  # +:result_init:+:: the starting value.  Defaults to 0.  If not 3-digit code then use the 3-digit code in arr. Otherwise its 3-digit code becomes the +base_currr+
  # +:convert:+:: if false then +Exception+ is raised when operations is performed on different currencies.
  # Return the result in currency with 3-digit code, or nil if +arr+ is nil
  def self.currency_op(arr, base_curr=nil, result_init=0, convert=false, logtag=nil)
    Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:currency_op:#{logtag}, arr.inspect:#{arr.inspect}, base_curr:#{base_curr}, result_init:#{result_init}, convert:#{convert}")
    result_str = nil
    if !arr.nil? and !arr.empty?
      if base_curr.nil?
        base_curr = self.get_currency_code(result_init)
        base_curr ||= self.get_currency_code(arr[0], logtag)
      end # end if base_curr.nil?
      result_curr_code, result = self.get_currency_code_and_val(result_init)
      # Check that currency is the same before performing operation
      arr.each { |elem|
        elem_curr = self.get_currency_code(elem)
        if !convert and elem_curr != base_curr
          Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:currency_op:#{logtag}, convert:#{convert} but elem:#{elem}, elem_curr:#{elem_curr} is not same as base_curr:#{base_curr}")
          raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:currency_op:#{logtag}, convert:#{convert} but elem:#{elem}, elem_curr:#{elem_curr} is not same as base_curr:#{base_curr}"
        elsif elem_curr != base_curr
          new_elem = self.convert_currency(elem, base_curr, logtag)
        else
          new_elem = elem
        end # end if !convert and self.get_currency_code(elem) != base_curr
        # Clean new_elem
        new_elem = self.get_currency_code_and_val(new_elem)[1]
        result = yield(result, new_elem)
      } # end arr.each ...
      result_str = base_curr + sprintf('%.2f', result)
    end # end if !arr.nil?
    result_str 
  end # end def self.currency_op

  # +:str:+:: contains the string will all currency we want to add
  # Return the result in currency with 3-digit code
  def self.sum_currency_in_str(str, default_value=nil, convert=false, logtag=nil)
    Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:sum_currency_in_str:#{logtag}, str:#{str}, default_value:#{default_value}, convert:#{convert}")
    currency_arr = self.get_currency_arr_from_str(str)
    sum_value = self.currency_op(currency_arr, nil, 0, convert) { |res, elem| res.to_f + elem.to_f } 
    sum_value ||= default_value
    sum_value
  end # end def self.sum_currency_in_str

  # +:main_str:+:: contains the string will all currency we want to add
  # +:subtract_str:+:: contains the string will all currency we want to subtract from +main_str+
  # Return the result in currency with 3-digit code
  def self.subtract_currency_in_str(main_str, subtract_str, default_value=nil, convert=false, logtag=nil)
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:subtract_currency_in_str:#{logtag}, main_str:#{main_str}, subtract_str:#{subtract_str}")
    main_str_value = self.sum_currency_in_str(main_str, 0)
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:subtract_currency_in_str:#{logtag}, main_str_value:#{main_str_value}")
    currency_arr = self.get_currency_arr_from_str(subtract_str)
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:subtract_currency_in_str:#{logtag}, currency_arr.inspect:#{currency_arr.inspect}")
    value = self.currency_op(currency_arr, nil, main_str_value, convert) { |res, elem| res.to_f - elem.to_f } 
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:subtract_currency_in_str:#{logtag}, value:#{value}")
    value ||= default_value
    value
  end # end def self.subtract_currency_in_str

  # Get the inbound_email text from inbound_email active record, i.e., 
  # get from subject, if not then get from body_text
  def self.get_text_from_inbound_email(inbound_email)
    orig_msg = inbound_email.subject
    if orig_msg.nil? or orig_msg.empty?
      orig_msg = inbound_email.body_text
    end # end if orig_msg.nil? or orig_msg.empty?
    orig_msg
  end # end def self.get_text_from_inbound_email

  # If we provide xxx.com/index.html?a=&b=5
  # then params[:a] is "" not nil
  # This is a problem, especially if we try to replace default value
  # using our_a = params[:a] followed by our_a ||= DEFAULT_A
  # +:default_value:+:: the default value to use
  # +:use_default_for_nil:+:: if nil then use default value
  # +:use_default_for_empty:+:: if nil then use default value
  def self.get_param(params, key, default_value=nil, use_default_for_nil=true, use_default_for_empty=true)
    val = params[key]
    return_val = ControllerHelper.get_default_value(val, default_value, use_default_for_nil, use_default_for_empty)
    return_val
  end # end def self.get_param

  # Replace with default value if value matches certain preset value,
  # e.g., replacing "" with nil
  # +:default_value:+:: the default value to use
  # +:use_default_for_nil:+:: if nil then use default value
  # +:use_default_for_empty:+:: if nil then use default value
  def self.get_default_value(val, default_value=nil, use_default_for_nil=true, use_default_for_empty=true)
    if !val.nil? and use_default_for_empty
      val = nil if val.empty?
    end # end if use_default_for_empty
    val ||= default_value
    val
  end # end def self.get_default_value

  # Takes into account the currency type to determine whether
  # to prefix value with currency code and use 2 decimal points
  # Derive the display string from +pii_property_set+ or any object that +responds_to?+ :currency and threshold
  # +:pii_property_set:+:: pii_property_set to derive from
  # Return +String+
  def self.threshold_display_str_from_pps(pii_property_set, logtag=nil)
    self.threshold_display_str_from_attr(pii_property_set.currency, pii_property_set.threshold, logtag)
  end # end def self.threshold_display_str_from_pps

  # Takes into account the currency type to determine whether
  # to prefix value with currency code and use 2 decimal points
  # Derive the display string from attrbutes given
  # +:currency_code:+:: Currency code
  # +:currency_value:+:: Currency value
  # Return +String+
  def self.threshold_display_str_from_attr(currency_code, currency_val, logtag=nil)
    return_curr_code = nil
    return_curr_val = nil
    if currency_code.nil? or currency_code.empty?
      if currency_val.to_i == currency_val.to_f
        return_curr_val = currency_val.to_i
      else
        return_curr_val = currency_val
      end # end if currency_val.to_i == currency_val.to_f
    else
      return_curr_val = sprintf('%.2f', currency_val)
      return_curr_code = currency_code
    end # end if currency_code.nil?
    return "#{return_curr_code}#{return_curr_val}"
  end # end def self.threshold_display_str_from_attr
end # end module ControllerHelper
