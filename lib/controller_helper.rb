require 'validators'

module ControllerHelper
  LOGTAG_MAX = 2**32

  MEANT_IT_INPUT_MESSAGE = :message
  MEANT_IT_INPUT_RECEIVER_PII = :receiver_pii
  MEANT_IT_INPUT_RECEIVER_NICK = :receiver_nick
  MEANT_IT_INPUT_TAGS = :tags

  def self.gen_logtag
    rand(LOGTAG_MAX)
  end # end def gen_logtag

  def self.parse_message_type_from_email_addr(email_addr, logtag = nil)
    message_type_str = nil
    email_addr_match_arr = nil
    email_addr_match_arr = email_addr.match /(.*)@.*/ if !email_addr.nil?
    if email_addr_match_arr.nil?
      message_type_str = MeantItMessageTypeValidator::MEANT_IT_MESSAGE_THANK
    else
      message_type_str = MessageTypeMapper.get_message_type(email_addr_match_arr[1])
    end # end if email_addr_match_arr.nil?
    message_type_str
  end # end def self.parse_message_type_from_email

  def self.parse_meant_it_input(input_str, logtag = nil)
    input_str_dup = input_str.dup if !input_str.nil?
    input_str_dup.downcase! if !input_str_dup.nil?
    result_hash = {}
    # Determine nick, :xxx, :yyy, tags
    # Get those strings enclosed with quotes ' or "
    # NOTE: scan returns [['abc'], ['def']... thus we use collect
    # to convert to [abc, def, ...]
    # Nick is the first tag, no spaces are allowed for nick
    # Message is enclosed within ;
    message_str_arr = input_str_dup.scan(/;(.*);/).collect { |elem| elem[0] }
    message_str = message_str_arr[0]
    result_hash[MEANT_IT_INPUT_MESSAGE] = message_str
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, message_str:#{message_str}")
    message_str_arr.each { |msg_elem| input_str_dup.sub!(/;#{msg_elem};/, '') }
    # Check for colon enclosed receiver pii
    receiver_pii_str_arr = input_str_dup.scan(/:(.*?):/).collect { |elem| elem[
0] }
    if receiver_pii_str_arr.empty?
      # If no colon enclosed receiver pii, check for pii starting with colon
      receiver_pii_str_arr = input_str_dup.scan(/:(.*?)\s/).collect { |elem| elem[0] }
      if receiver_pii_str_arr.empty?
        receiver_pii_str_arr = input_str_dup.scan(/:(.*?)$/).collect { |elem| elem[0] }
      end
      receiver_pii_str_arr.each { |receiver_pii_elem| input_str_dup.sub!(/:#{receiver_pii_elem}/, '') }
    else
      receiver_pii_str_arr.each { |receiver_pii_elem| input_str_dup.sub!(/:#{receiver_pii_elem}:/, '') }
    end # end if receiver_pii_str_arr.nil?
    receiver_pii_str = receiver_pii_str_arr[0]
    result_hash[MEANT_IT_INPUT_RECEIVER_PII] = receiver_pii_str
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, receiver_pii_str:#{receiver_pii_str}")
    single_quote_tag_arr = input_str_dup.scan(/'(.*?)'/).collect { |elem| elem[0] }
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, single_quote_tag_arr.inspect:#{single_quote_tag_arr.inspect}")
    # Remove those quoted tags since we've processed them
    single_quote_tag_arr.each { |tag_elem| input_str_dup.sub!(/'#{tag_elem}'/, '') }
    double_quotes_tag_arr = input_str_dup.scan(/"(.*?)"/).collect { |elem| elem[0] }
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, double_quotes_tag_arr.inspect:#{double_quotes_tag_arr.inspect}")
    double_quotes_tag_arr.each { |tag_elem| input_str_dup.sub!(/"#{tag_elem}"/, '') }
    tag_str_arr = single_quote_tag_arr + double_quotes_tag_arr
    input_str_arr = input_str_dup.split
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, stripped input_str_arr.inspect:#{input_str_arr.inspect}")
    receiver_nick_str = input_str_arr.shift
    result_hash[MEANT_IT_INPUT_RECEIVER_NICK] = receiver_nick_str
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, receiver_nick_str:#{receiver_nick_str}")
    tag_str_arr += input_str_arr
    tag_str_arr.uniq!
    Rails.logger.info("#{File.basename(__FILE__)}:#{self.class}:parse_meant_it_input:#{logtag}, tag_str_arr.inspect:#{tag_str_arr.inspect}")
    result_hash[MEANT_IT_INPUT_TAGS] = tag_str_arr
    result_hash
  end # end def.parse_meant_it_text

  def self.find_person_by_id(person_id, logtag=nil)
    person = nil
    begin
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_person_by_id:#{logtag}, person_id:#{person_id}")
      person = Person.find(person_id)
    rescue Exception => e
    end # end cannot find person from couchdb
    if person.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_person_by_id:#{logtag}, person find triggered exception, e.inspect:#{e.inspect}")
      # Use sql instead of couchdb
      person = EntityDatum.find_by_id(person_id)
    end # end if person.nil?
    person
  end # end def self.find_person_by_id

  def self.find_person_by_email(name, email, logtag=nil)
    person = nil
    begin
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_person_by_email:#{logtag}, name:#{name}, email:#{email}")
      person = Person.find_by_email(email)
    rescue Exception => e
    end # end cannot find person from couchdb
    if person.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_person_by_email:#{logtag}, person find triggered exception, e.inspect:#{e.inspect}")
      # Use sql instead of couchdb
      person = EntityDatum.find_by_email(:email => email)
    end # end if person.nil?
    person
  end # end def self.find_person_by_email(name, email, logtag=nil)

  def self.find_or_create_person_by_email(name, email, logtag=nil)
    new_person = nil
    begin
      # Create propertyId
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_or_create_person_by_email:#{logtag}, name:#{name}, email:#{email}")
      new_person = Person.find_by_email(email)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_or_create_person_by_email:#{logtag}, find_by_email new_person:#{new_person.inspect}")
      if new_person.nil?
        new_person = Person.create(:name => name, :email => email)
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_or_create_person_by_email:#{logtag}, create new_person:#{new_person.inspect}")
      end # end if new_person.nil?
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_or_create_person_by_email:#{logtag}, new_person.errors:#{new_person.errors.inspect}")
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_or_create_person_by_email:#{logtag}, new_person:#{new_person.inspect}")
   rescue Exception => e
      # Usually because couchdb is not there
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:find_or_create_person_by_email:#{logtag}, person find/create triggered exception, e.inspect:#{e.inspect}")
      # Use sql instead of couchdb
      new_person = EntityDatum.find_or_create_by_email(:email => email)
   end # end find/create person
   new_person
  end # end def self.find_or_create_person_by_email

  PII_VALUE_STR = :pii_value_str
  PII_TYPE = :pii_type
  PII_HIDE = :pii_hide
  def self.get_pii_hash(initial_pii_value_str)
    final_pii_value_str = initial_pii_value_str
    pii_type = PiiTypeValidator::PII_TYPE_GLOBAL
    pii_hide = PiiHideTypeValidator::PII_HIDE_FALSE
    if !final_pii_value_str.nil?
      if (match_arr = initial_pii_value_str.match(/.*@.*\..*/))
        pii_type = PiiTypeValidator::PII_TYPE_EMAIL
        pii_hide = PiiHideTypeValidator::PII_HIDE_TRUE
      elsif (match_arr = sender_str.match(/(.*)\$(.*)/))
        pii_type = match_arr[2]
        pii_hide = PiiHideTypeValidator::PII_HIDE_TRUE
        final_pii_value_str = match_arr[1]
        if PiiTypeValidator::PII_TYPE_ENUM.index(pii_type).nil?
          pii_type = PiiTypeValidator::PII_TYPE_OTHER
        end # end if PiiTypeValidator::PII_TYPE_ENUM.index(pii_type)
      end # end if initial_pii_value_str.match ...
      if initial_pii_value_str.match(/.*\$$/)
        # Ends with $ then we set to hide
        pii_hide = PiiHideTypeValidator::PII_HIDE_TRUE
      end # end if initial_pii_value_str.match ...
    end # end if !final_pii_value_str.nil?
    { PII_VALUE_STR => final_pii_value_str, PII_TYPE => pii_type, PII_HIDE => pii_hide }
  end # end def self.get_pii_type
end # end module ControllerHelper
