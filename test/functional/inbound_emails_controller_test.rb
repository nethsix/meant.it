require 'test_helper'
require 'validators'

class InboundEmailsControllerTest < ActionController::TestCase
  setup do
# To use inbound_emails() we need to use fixtures(?)
#    @inbound_email = inbound_emails(:nick_y_xxx_n_yyy_y_tags_y_sender_idable_inbound_email)
    @inbound_email = InboundEmail.first
  end

  test "should get index" do
    get :index
#CODE!!!    assert_response :success
#CODE!!!    assert_not_nil assigns(:inbound_emails)
  end

  test "should get new" do
    get :new
#CODE!!!    assert_response :success
  end

#  test "should create inbound_email" do
#    assert_difference('InboundEmail.count') do
#      post :create, :inbound_email => @inbound_email.attributes
#    end
#
#    assert_redirected_to inbound_email_path(assigns(:inbound_email))
#  end

  test "nick_y_xxx_n_yyy_y_tags_y_sender_idable_inbound_email" do
   email_elem = inbound_emails(:nick_y_xxx_n_yyy_y_tags_y_sender_idable_inbound_email)
   common_code(email_elem)
  end # end "nick_y_xxx_n_yyy_y_tags_y_sender_idable_inbound_email"

  test "nick_y_xxx_n_yyy_n_tags_y_sender_idable_inbound_email" do
   email_elem = inbound_emails(:nick_y_xxx_n_yyy_n_tags_y_sender_idable_inbound_email)
   common_code(email_elem)
  end # end "nick_y_xxx_n_yyy_n_tags_y_sender_idable_inbound_email"

  test "nick_y_xxx_n_yyy_y_tags_n_sender_idable_inbound_email" do
   email_elem = inbound_emails(:nick_y_xxx_n_yyy_y_tags_n_sender_idable_inbound_email)
   common_code(email_elem)
  end # end "nick_y_xxx_n_yyy_y_tags_n_sender_idable_inbound_email"

  test "nick_y_xxx_n_yyy_n_tags_n_sender_idable_inbound_email" do
   email_elem = inbound_emails(:nick_y_xxx_n_yyy_n_tags_n_sender_idable_inbound_email)
   common_code(email_elem)
  end # end "nick_y_xxx_n_yyy_n_tags_n_sender_idable_inbound_email"

  test "nick_y_xxx_y_yyy_y_tags_y_sender_idable_inbound_email" do
   email_elem = inbound_emails(:nick_y_xxx_y_yyy_y_tags_y_sender_idable_inbound_email)
   common_code(email_elem)
  end # end "nick_y_xxx_y_yyy_y_tags_y_sender_idable_inbound_email"

  test "nick_y_xxx_y_yyy_n_tags_y_sender_idable_inbound_email" do
   email_elem = inbound_emails(:nick_y_xxx_y_yyy_n_tags_y_sender_idable_inbound_email)
   common_code(email_elem)
  end # end "nick_y_xxx_y_yyy_n_tags_y_sender_idable_inbound_email"

  test "nick_y_xxx_y_yyy_y_tags_n_sender_idable_inbound_email" do
   email_elem = inbound_emails(:nick_y_xxx_y_yyy_y_tags_n_sender_idable_inbound_email)
   common_code(email_elem)
  end # end "nick_y_xxx_y_yyy_y_tags_n_sender_idable_inbound_email"

  test "nick_y_xxx_y_yyy_n_tags_n_sender_idable_inbound_email" do
   email_elem = inbound_emails(:nick_y_xxx_y_yyy_n_tags_n_sender_idable_inbound_email)
   common_code(email_elem)
  end # end "nick_y_xxx_y_yyy_n_tags_n_sender_idable_inbound_email"

  test "nick_n_xxx_y_yyy_y_tags_y_sender_idable_inbound_email" do
   email_elem = inbound_emails(:nick_n_xxx_y_yyy_y_tags_y_sender_idable_inbound_email)
   common_code(email_elem)
  end # end "nick_n_xxx_y_yyy_y_tags_y_sender_idable_inbound_email"

  test "nick_n_xxx_y_yyy_n_tags_y_sender_idable_inbound_email" do
   email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_sender_idable_inbound_email)
   common_code(email_elem)
  end # end "nick_n_xxx_y_yyy_n_tags_y_sender_idable_inbound_email"

  test "nick_n_xxx_y_yyy_y_tags_n_sender_idable_inbound_email" do
   email_elem = inbound_emails(:nick_n_xxx_y_yyy_y_tags_n_sender_idable_inbound_email)
   common_code(email_elem)
  end # end "nick_n_xxx_y_yyy_y_tags_n_sender_idable_inbound_email"

  test "nick_n_xxx_y_yyy_n_tags_n_sender_idable_inbound_email" do
   email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_n_sender_idable_inbound_email)
   common_code(email_elem)
  end # end test "nick_n_xxx_y_yyy_n_tags_n_sender_idable_inbound_email"

  test "xxx_no_colon_inbound_email" do
   email_elem = inbound_emails(:xxx_no_colon_inbound_email)
   common_code(email_elem)
  end # end test "xxx_no_colon_inbound_email"

  # NOTE: if post_url is not inbound_emails_200 which is hidden
  # then from: is not used to prevent people from faking email senders
  # instead anon or session login id is used.  See controller for details.
  def common_code(email_elem, post_url = Constants::SENDGRID_PARSE_URL)
    p "testing inbound_email.inspect:#{email_elem.inspect}"

    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    p "meantItRel_hash.inspect:#{meantItRel_hash.inspect}"
    receiver_pii_count = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII].nil? ? 0 : 1
    message_type_str = ControllerHelper.parse_message_type_from_email_addr(email_elem.to)
p "email_elem.to:#{email_elem.to}"
p "message_type_str:#{message_type_str}"
    endpoint_tag_arr = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_TAGS].dup
    p "BBBBBBBB #{email_elem.body_text} BBBBBBB endpoint_tag_arr:#{endpoint_tag_arr.inspect}"
    # Check each tag for existance
    non_exist_endpoint_tag_arr = []
    endpoint_tag_arr.each { |tag_elem|
      non_exist_endpoint_tag_arr << tag_elem if !Tag.exists?(:name => tag_elem)
    }  # end input_tag_arr.each ...
    mood_tag_arr = []
    if message_type_str == MeantItMessageTypeValidator::MEANT_IT_MESSAGE_OTHER
      # CODE!!!! Get mood tags using reasoner
      # mood_tag_arr += ...
    else
      mood_tag_arr << message_type_str
    end # end if message_type_str == MeantItMessageTypeValidator:: ...
    p "mood_tag_arr:#{mood_tag_arr.inspect}"
    non_exist_mood_tag_arr = []
    mood_tag_arr.each { |tag_elem|
      non_exist_mood_tag_arr << tag_elem if !Tag.exists?(:name => tag_elem)
    }  # end mood_tag_arr.each ...
    p "#AAAA non_exist_mood_tag_arr.inspect:#{non_exist_mood_tag_arr.inspect}"

    receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    auto_entity = nil
    if (auto_entity_arr = ControllerHelper.auto_entity_domain?(receiver_pii_str))
      auto_entity = Entity.find(auto_entity_arr[ControllerHelper::AUTO_ENTITY_DOMAIN_ENTITY_ID]) if !auto_entity_arr.nil?
    end # end if (auto_entity_arr = ControllerHelper.auto_entity_domain? ...
    endPoint_count = auto_entity.nil? ? 2 : 3

    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', endPoint_count],
      ['Pii.count', 1+receiver_pii_count],
#20110713      ['Entity.count', 1],
#20110713      ['EntityDatum.count', 1],
#20110713      ['EntityEndPointRel.count', 1],
      ['Tag.count', non_exist_endpoint_tag_arr.size + non_exist_mood_tag_arr.size],
      ['EndPointTagRel.count', endpoint_tag_arr.size],
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', non_exist_mood_tag_arr.size]
      ]) do
      @request.path = post_url if !post_url.nil?
      post :create, :inbound_email => email_elem.attributes
    end

p "MeantItMoodTagRel.count:#{MeantItMoodTagRel.count}"
p "MeantItMoodTagRel.all:#{MeantItMoodTagRel.all.inspect}"

    if post_url == Constants::SENDGRID_PARSE_URL
      assert_response :success
    else
      assert_redirected_to inbound_email_path(assigns(:inbound_email))
    end # end if post_url == Constants::SENDGRID_PARSE_URL

    # Check that email is created
    inbound_email_from_db = InboundEmail.find_by_id(assigns(:inbound_email)["id"])
    assert_not_nil inbound_email_from_db

    # Check that sender Pii
    sender_pii_email_hash = ControllerHelper.parse_email(email_elem.from)
    sender_pii_str = sender_pii_email_hash[ControllerHelper::EMAIL_STR]
    sender_pii_nick_str = sender_pii_email_hash[ControllerHelper::EMAIL_NICK_STR]
    if post_url !=  Constants::SENDGRID_PARSE_URL
      sender_pii_str = "anonymous"
      sender_pii_nick_str = nil
    end # end if post_url !=  Constants::SENDGRID_PARSE_URL
    sender_pii_hash = ControllerHelper.get_pii_hash(sender_pii_str)
    sender_pii = Pii.find_by_pii_value(sender_pii_hash[ControllerHelper::PII_VALUE_STR])
    assert_not_nil sender_pii

    # Check that sender EndPoint is created
#20110628a      sender_endPoint = sender_pii.endPoint
#20110628a      assert_not_nil sender_endPoint
    sender_endPoint_arr = sender_pii.endPoints
    assert_equal 1, sender_endPoint_arr.size
    sender_endPoint = sender_endPoint_arr[0]
    if post_url !=  Constants::SENDGRID_PARSE_URL
      assert_equal "anonymous", sender_endPoint.pii.pii_value
    else
      assert_equal sender_pii_str, sender_endPoint.pii.pii_value
    end # end if post_url != Constants::SENDGRID_PARSE_URL

#20110713    # Check that sender Entity is created
#20110713    sender_entities = sender_endPoint.entities
#20110713    assert_equal 1, sender_entities.size
#20110713    sender_entity = sender_entities[0]
#20110713    assert_not_nil sender_entity
#20110713    # Check that sender Entity has the same pii
#20110713    person = ControllerHelper.find_person_by_id(sender_entity.property_document_id)
#20110713    assert_equal person.email, sender_pii.pii_value

#20110713    # Check that verification_type is email
#20110713    assert_equal 1, sender_entity.entityEndPointRels.size
#20110713    sender_entity_entityEndPointRel = sender_entity.entityEndPointRels[0]
#20110713    assert_equal VerificationTypeValidator::VERIFICATION_TYPE_EMAIL, sender_entity_entityEndPointRel.verification_type

    # Check receiver_endPoint
    receiver_nick_str =  meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    receiver_pii_hash = ControllerHelper.get_pii_hash(receiver_pii_str)
    receiver_pii_str = receiver_pii_hash[ControllerHelper::PII_VALUE_STR]
    receiver_endPoint = EndPoint.find_by_creator_endpoint_id_and_nick(sender_endPoint.id, receiver_nick_str) if !receiver_nick_str.nil? and !receiver_nick_str.empty?
    # Try getting by pii if nick is not provided
    if receiver_endPoint.nil? and !receiver_pii_str.nil? and !receiver_pii_str.empty?
      receiver_endPoint_arr =  EndPoint.find(:all, :conditions => { :creator_endpoint_id => sender_endPoint.id})
      receiver_endPoint_arr.each { |receiver_ep|
        if !receiver_ep.pii.nil? and receiver_ep.pii.pii_value == receiver_pii_str
          receiver_endPoint = receiver_ep
          break
        end # end if !receiver_ep.pii.nil?
      } # end receiver_endPoint_arr ...
    end # end if receiver_endPoint.nil? ...
    assert_not_nil receiver_endPoint
    if receiver_pii_str.nil? or receiver_pii_str.empty?
      assert_nil receiver_endPoint.pii
    else # else if !receiver_pii_str.nil? and !receiver_pii_str.empty?
      assert_equal receiver_pii_str, receiver_endPoint.pii.pii_value
    end # end # else if !receiver_pii_str.nil? and !receiver_pii_str.empty?

    # Check receiver_endPoint tags
    p "meantItRel_hash.inspect:#{meantItRel_hash.inspect}"
    tag_str_arr = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_TAGS]
    p "tag_str_arr:#{tag_str_arr}"
    tagged_endPoints = EndPoint.tagged(tag_str_arr)
    p "tagged_endPoints.inspect:#{tagged_endPoints.inspect}"
    tagged_endPoint = tagged_endPoints[0]
    if tag_str_arr.nil? or tag_str_arr.empty?
      assert_equal 0, tagged_endPoints.size
    else
      assert_equal 1, tagged_endPoints.size
      assert_equal receiver_endPoint, tagged_endPoint
    end # end if tag_str_arr.nil? ...
    
    # Check that MeantItRel is related to sender_endPoint and receiver_endPoint
    assert_equal 1, sender_endPoint.srcMeantItRels.size
    assert_equal receiver_endPoint.id, sender_endPoint.srcMeantItRels[0].dst_endpoint.id
    assert_equal 1, receiver_endPoint.dstMeantItRels.size
    assert_equal sender_endPoint.id, receiver_endPoint.dstMeantItRels[0].src_endpoint.id
    assert_equal sender_endPoint.srcMeantItRels[0], receiver_endPoint.dstMeantItRels[0]
    # Check that MeantItRel is related to email
    assert_equal inbound_email_from_db.id, sender_endPoint.srcMeantItRels[0].inbound_email_id
    assert_equal inbound_email_from_db.id, receiver_endPoint.dstMeantItRels[0].inbound_email_id
    # Check meantIt type
    assert_equal message_type_str, sender_endPoint.srcMeantItRels[0].message_type
    # Check mood tags
    if sender_endPoint.srcMeantItRels[0].message_type == MeantItMessageTypeValidator::MEANT_IT_MESSAGE_OTHER
      # CODE!!!! Check with reaonser
    else
      meantItMoodTags = sender_endPoint.srcMeantItRels[0].tags
      meantItMoodTag = meantItMoodTags[0]
      assert_equal 1, meantItMoodTags.size
      assert_equal MeantItMoodTagRel::MOOD_TAG_TYPE, meantItMoodTag.desc
      assert_equal message_type_str, meantItMoodTag.name
    end # end if sender_endPoint.srcMeantItRels[0].message_type == MeantItMessageTypeValidator::MEANT_IT_MESSAGE_OTHER

    # Check auto_entity association
    if auto_entity
      auto_entity.reload
      assert_not_nil auto_entity.endPoints
      auto_entity_endpoint_association_found = false
      auto_entity.endPoints.each { |auto_entity_ep_elem|
        if !auto_entity_ep_elem.pii.nil? and auto_entity_ep_elem.pii.pii_value == receiver_pii_str
          auto_entity_endpoint_association_found = true if auto_entity_ep_elem.creator_endpoint_id == auto_entity_ep_elem.id
        end # end if auto_entity_ep_elem.pii_value == receiver_pii_str
      } # end auto_entity.endPoints.each ...
      assert auto_entity_endpoint_association_found
    end # end if auto_entity
      
p "#AAAAA MeantItMoodTagRel.count:#{MeantItMoodTagRel.count}"
p "#AAAAA MeantItMoodTagRel.all:#{MeantItMoodTagRel.all.inspect}"
  end # end def common_code

  # Tests for source that is global id-able, i.e., email

  test "should create inbound_email twice but not sender or receiver endpoint" do
    # Send the same message twice
    first_inbound_email = inbound_emails(:nick_y_xxx_y_yyy_y_tags_y_sender_idable_inbound_email)
    input_str = first_inbound_email.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2],
#20110713      ['Entity.count', 1],
      ['Pii.count', 2],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success

    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 0],
#20110713      ['Entity.count', 0],
      ['Pii.count', 0],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success
  end # end test "should create inbound_email twice but not sender or receiver endpoint"

  test "same sender same receiver endpoint, with nick and pii later same nick no pii" do
    first_inbound_email = inbound_emails(:nick_y_xxx_y_yyy_y_tags_y_sender_idable_inbound_email)
    input_str = first_inbound_email.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    receiver_nick_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2],
#20110713      ['Entity.count', 1],
      ['Pii.count', 2],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success

    # Use the same nick but no pii
    # Should pick up existing receiver_endPoint based on 
    # sender_endPoint id = creator_endpoint_id and nick
    body_text = first_inbound_email.body_text
    mutated_body_text = "#{receiver_nick_str} ;hello!!!; kitty town"
    first_inbound_email.body_text = mutated_body_text

    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 0],
#20110713      ['Entity.count', 0],
      ['Pii.count', 0],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success
    final_receiver_pii = Pii.find_by_pii_value(receiver_pii_str)
    assert_equal 1, final_receiver_pii.endPoints.size
    assert_equal receiver_nick_str, final_receiver_pii.endPoints[0].nick
  end # end test "same sender same receiver endpoint, with nick and pii later same nick no pii"

  test "same sender different receiver endpoint, with nick and pii later no nick same pii" do
    first_inbound_email = inbound_emails(:nick_y_xxx_y_yyy_y_tags_y_sender_idable_inbound_email)
    input_str = first_inbound_email.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    receiver_nick_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2],
#20110713      ['Entity.count', 1],
      ['Pii.count', 2],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success

    # Use the same pii but no nick
    # Should create new receiver_endPoint tied to same pii
    body_text = first_inbound_email.body_text
    mutated_body_text = ":#{receiver_pii_str} ;hello!!!; kitty town"
    first_inbound_email.body_text = mutated_body_text

    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 1],
#20110713      ['Entity.count', 0],
      ['Pii.count', 0],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success
    final_receiver_pii = Pii.find_by_pii_value(receiver_pii_str)
    assert_equal 2, final_receiver_pii.endPoints.size
    nil_nick = final_receiver_pii.endPoints.select { |ep_elem| ep_elem.nick == nil }
    correct_nick = final_receiver_pii.endPoints.select { |ep_elem| ep_elem.nick == receiver_nick_str }
    assert_not_nil nil_nick
    assert_not_nil correct_nick
  end # end test "same sender different receiver endpoint, with nick and pii later no nick same pii"

  test "same sender same receiver endpoint, no nick and with pii later no nick same pii" do
    first_inbound_email = inbound_emails(:nick_n_xxx_y_yyy_y_tags_y_sender_idable_inbound_email)
    input_str = first_inbound_email.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    receiver_nick_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2],
#20110713      ['Entity.count', 1],
      ['Pii.count', 2],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success

    # Use the same pii but no nick
    # Should reuse the receiver_endPoint with no nick tied to same pii

    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 0],
#20110713      ['Entity.count', 0],
      ['Pii.count', 0],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success
    final_receiver_pii = Pii.find_by_pii_value(receiver_pii_str)
    assert_equal 1, final_receiver_pii.endPoints.size
    nil_nick = final_receiver_pii.endPoints.select { |ep_elem| ep_elem.nick == nil }
    assert_not_nil nil_nick
  end # end test "same sender same receiver endpoint, no nick with pii later no nick same pii"

  test "different sender different receiver endpoint, with nick and pii later same nick same pii as another previous sender" do
    first_inbound_email = inbound_emails(:nick_y_xxx_y_yyy_y_tags_y_sender_idable_inbound_email)
    input_str = first_inbound_email.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    receiver_nick_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2],
#20110713      ['Entity.count', 1],
      ['Pii.count', 2],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success

    # Use the same nick same pii as another sender
    # Should create new receiver_endPoint tied to same pii
    kuromi_sender_pii_str = "kuromi@gmail.com"
    first_inbound_email.from = kuromi_sender_pii_str

    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # kuromi sender, and kuromi's receiver
#20110713      ['Entity.count', 1],
      ['Pii.count', 1], # kuromi sender
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success
    final_receiver_pii = Pii.find_by_pii_value(receiver_pii_str)
    assert_equal 2, final_receiver_pii.endPoints.size
    kitty_pii = Pii.find_by_pii_value(first_inbound_email.from)
    assert 1, kitty_pii.endPoints.size
    kitty_ep = kitty_pii.endPoints[0]
    kitty_receiver_ep = EndPoint.find_by_nick_and_creator_endpoint_id(receiver_nick_str, kitty_ep.id)
    assert_not_nil final_receiver_pii.endPoints.index(kitty_receiver_ep)
    kuromi_pii = Pii.find_by_pii_value(kuromi_sender_pii_str)
    assert 1, kuromi_pii.endPoints.size
    kuromi_ep = kuromi_pii.endPoints[0]
    kuromi_receiver_ep = EndPoint.find_by_nick_and_creator_endpoint_id(receiver_nick_str, kitty_ep.id)
    assert_not_nil final_receiver_pii.endPoints.index(kuromi_receiver_ep)
  end # end test "different sender different receiver endpoint, with nick and pii later same nick same pii as another previous sender"

  test "same sender same receiver endpoint, with nick and no pii later same nick with pii" do
    first_inbound_email = inbound_emails(:nick_y_xxx_n_yyy_y_tags_y_sender_idable_inbound_email)
    input_str = first_inbound_email.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    receiver_nick_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2],
#20110713      ['Entity.count', 1],
      ['Pii.count', 1],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success
    sender_email_str = first_inbound_email.from
    sender_email_hash = ControllerHelper.parse_email(sender_email_str)
    sender_pii_str = sender_email_hash[ControllerHelper::EMAIL_STR]
    kitty_pii = Pii.find_by_pii_value(sender_pii_str)
    assert 1, kitty_pii.endPoints.size
    kitty_ep = kitty_pii.endPoints[0]
    assert 1, kitty_ep.srcMeantItRels.size
    receiver_ep = kitty_ep.srcMeantItRels[0].dst_endpoint
    assert receiver_nick_str, receiver_ep.nick

    # Use the same nick but now with pii
    # Should create new receiver_endPoint tied to same pii
    body_text = first_inbound_email.body_text
    new_pii = "new_kitty@gmail.com"
    mutated_body_text = "#{body_text} :#{new_pii}"
    first_inbound_email.body_text = mutated_body_text

    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 0],
#20110713      ['Entity.count', 0],
      ['Pii.count', 1],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success
    final_receiver_pii = Pii.last
    assert_equal new_pii, final_receiver_pii.pii_value
    assert_equal 1, final_receiver_pii.endPoints.size
    assert_equal receiver_ep, final_receiver_pii.endPoints[0]
  end # end test "same sender same receiver endpoint, with nick and no pii later same nick with pii"

  test "CODE!!!!" do
    # Test all four cases of nick/pii empty/yes
  end # end test "should create inbound_email but not sender endpoint" do

  test "should generate inbound_email_log but response success" do
    first_inbound_email = InboundEmail.first
    # Create error condition
    first_inbound_email.attachment_count = nil
p "#### first_inbound_email:#{first_inbound_email.inspect}"
    assert_differences([
      ['InboundEmailLog.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success
    inbound_email_log_last = InboundEmailLog.last
    assert_match /#{first_inbound_email.to}/, inbound_email_log_last.params_txt
    assert_match /#{first_inbound_email.from}/, inbound_email_log_last.params_txt
    assert_match /#{first_inbound_email.body_text}/, inbound_email_log_last.params_txt
    assert_match /attachment/, inbound_email_log_last.error_msgs
    assert_match /attachment/, inbound_email_log_last.error_objs
  end # end test "should generate inbound_email_log but response success" do

  test "should generate error field in inbound_email but response success" do
    first_inbound_email = inbound_emails(:nick_y_xxx_y_yyy_y_tags_y_sender_idable_inbound_email)
    input_str = first_inbound_email.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    p "#### inbound_email_last #1:#{InboundEmail.last.body_text}"

    # Create error condition
    # Change receiver_pii_str in body_text
    body_text = first_inbound_email.body_text
p "#AAAAAAA b4 body_text:#{body_text}"
    body_text.sub!(receiver_pii_str, "#{receiver_pii_str}_mutated") if !body_text.nil? and !receiver_pii_str.nil?
p "#AAAAAAA after body_text:#{body_text}"
    first_inbound_email.body_text = body_text

    assert_differences([
      ['InboundEmail.count', 1],
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success
    inbound_email_last = InboundEmail.last
    p "#### inbound_email_last #2:#{InboundEmail.last.body_text}"
    p "#### inbound_email_last #2:#{InboundEmail.last.error_msgs}"
    p "#### inbound_email_last #2:#{InboundEmail.last.error_objs}"
    assert_match /already has pii_value '#{receiver_pii_str}/, inbound_email_last.error_msgs
    assert_match /OrderedHash/, inbound_email_last.error_objs
  end # end test "should generate error field in inbound_email but response success" do

  test "should populate error field in inbound_email" do
  end # end test "should populate error field in inbound_email" do

  test "should show inbound_email" do
#CODE!!!    get :show, :id => @inbound_email.to_param
#CODE!!!    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @inbound_email.to_param
#CODE!!!    assert_response :success
  end

  test "should update inbound_email" do
    put :update, :id => @inbound_email.to_param, :inbound_email => @inbound_email.attributes
#CODE!!!    assert_redirected_to inbound_email_path(assigns(:inbound_email))
  end

  test "should destroy inbound_email" do
#CODE!!!    assert_difference('InboundEmail.count', -1) do
#CODE!!!      delete :destroy, :id => @inbound_email.to_param
#CODE!!!    end

#CODE!!!    assert_redirected_to inbound_emails_path
  end

  test "inbound_emails_200 should lead to create action and xml" do
    assert_recognizes({:controller => "inbound_emails", :action => "create", :format => "xml"}, {:path => Constants::SENDGRID_PARSE_URL, :method => :post})
  end

  test "pii with only preceding colon" do
    pii_at_start_input_str = ":hello kitty ;why don't you have a mouth?; sanrio tokyo"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(pii_at_start_input_str)

    assert_equal 'hello', meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    pii_at_mid_input_str = ";why don't you have a mouth?; :hello kitty sanrio tokyo"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(pii_at_mid_input_str)
    assert_equal 'hello', meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    pii_at_end_input_str = "sanrio ;why don't you have a mouth?; tokyo kitty :hello"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(pii_at_end_input_str)
    assert_equal 'hello', meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
  end # end test "pii with only  preceding colon"

  test "pii enclosed with colon" do
    pii_at_start_input_str = ":hello kitty: ;why don't you have a mouth?; sanrio tokyo"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(pii_at_start_input_str)
    receiver_pii_hash = ControllerHelper.get_pii_hash(meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII])
    assert_equal 'hello kitty', receiver_pii_hash[ControllerHelper::PII_VALUE_STR]
    assert_equal PiiTypeValidator::PII_TYPE_GLOBAL, receiver_pii_hash[ControllerHelper::PII_TYPE]
    assert_equal PiiHideTypeValidator::PII_HIDE_FALSE, receiver_pii_hash[ControllerHelper::PII_HIDE]
    pii_at_mid_input_str = ";why don't you have a mouth?; :hello kitty: sanrio tokyo"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(pii_at_mid_input_str)
    receiver_pii_hash = ControllerHelper.get_pii_hash(meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII])
    assert_equal 'hello kitty', receiver_pii_hash[ControllerHelper::PII_VALUE_STR]
    assert_equal PiiTypeValidator::PII_TYPE_GLOBAL, receiver_pii_hash[ControllerHelper::PII_TYPE]
    assert_equal PiiHideTypeValidator::PII_HIDE_FALSE, receiver_pii_hash[ControllerHelper::PII_HIDE]
    pii_at_end_input_str = "sanrio ;why don't you have a mouth?; tokyo :hello kitty:"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(pii_at_end_input_str)
    receiver_pii_hash = ControllerHelper.get_pii_hash(meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII])
    assert_equal 'hello kitty', receiver_pii_hash[ControllerHelper::PII_VALUE_STR]
    assert_equal PiiTypeValidator::PII_TYPE_GLOBAL, receiver_pii_hash[ControllerHelper::PII_TYPE]
    assert_equal PiiHideTypeValidator::PII_HIDE_FALSE, receiver_pii_hash[ControllerHelper::PII_HIDE]
  end # end test "pii enclosed with colon" do

  test "pii with auto assign pii_type pii_hide" do
    pii_with_no_dollar = ":hello_kitty@sanrio.com ;why don't you have a mouth?; sanrio tokyo"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(pii_with_no_dollar)

    receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    receiver_pii_hash = ControllerHelper.get_pii_hash(receiver_pii_str)
    assert_equal 'hello_kitty@sanrio.com', receiver_pii_hash[ControllerHelper::PII_VALUE_STR]
    assert_equal PiiTypeValidator::PII_TYPE_EMAIL, receiver_pii_hash[ControllerHelper::PII_TYPE]
    assert_equal PiiHideTypeValidator::PII_HIDE_TRUE, receiver_pii_hash[ControllerHelper::PII_HIDE]
    pii_with_dollar_at_end = ";wow, you are rich; :hello kitty's treasure$: sanrio tokyo"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(pii_with_dollar_at_end)
    receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    receiver_pii_hash = ControllerHelper.get_pii_hash(receiver_pii_str)
   
    assert_equal "hello kitty's treasure", receiver_pii_hash[ControllerHelper::PII_VALUE_STR]
    assert_equal PiiTypeValidator::PII_TYPE_OTHER, receiver_pii_hash[ControllerHelper::PII_TYPE]
    assert_equal PiiHideTypeValidator::PII_HIDE_TRUE, receiver_pii_hash[ControllerHelper::PII_HIDE]
    pii_with_dollar_at_mid = ";wow, you are rich; :hellokitty$ssn: sanrio tokyo"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(pii_with_dollar_at_mid)
    receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    receiver_pii_hash = ControllerHelper.get_pii_hash(receiver_pii_str)
    assert_equal "hellokitty", receiver_pii_hash[ControllerHelper::PII_VALUE_STR]
    assert_equal PiiTypeValidator::PII_TYPE_SSN, receiver_pii_hash[ControllerHelper::PII_TYPE]
    assert_equal PiiHideTypeValidator::PII_HIDE_TRUE, receiver_pii_hash[ControllerHelper::PII_HIDE]
  end # end test "pii with auto assign pii_type pii_hide" do

  test "non-email pii nick" do
    email_pii = "jslv tall t-shirt ;coolsnowboard t-shirt; :feedback@jslvcorp.com"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(email_pii)
    pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    nick_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    assert_equal "feedback@jslvcorp.com", pii_str
    assert_equal "jslv", nick_str
    non_email_pii = "tall t-shirt ;coolsnowboard t-shirt; :jslv"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(non_email_pii)
    pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    nick_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    assert_equal "jslv", pii_str
    assert_equal "jslv", nick_str
    non_email_pii_with_space = "skateboard shoes ;cool shoes; :es keswick:"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(non_email_pii_with_space)
    pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    nick_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    assert_equal "es keswick", pii_str
    assert_equal "es_keswick", nick_str
    non_email_hide_pii = "jslvcorp tall t-shirt ;coolsnowboard t-shirt; :jslv$"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(non_email_hide_pii)
    pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    nick_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
    assert_equal "jslv$", pii_str
    assert_equal "jslvcorp", nick_str
  end # end test "non-email pii nick"

  test "parse email string to get nick and email" do
    email_str = '"kuromi" <kuromi@sanrio.com>'
    email_hash = ControllerHelper.parse_email(email_str)
    email = email_hash[ControllerHelper::EMAIL_STR]
    email_nick = email_hash[ControllerHelper::EMAIL_NICK_STR]
    assert "kuromi", email_nick
    assert_equal "kuromi@sanrio.com", email

    email_str = "'kuromi' <kuromi@sanrio.com>"
    email_hash = ControllerHelper.parse_email(email_str)
    email = email_hash[ControllerHelper::EMAIL_STR]
    email_nick = email_hash[ControllerHelper::EMAIL_NICK_STR]
    assert "kuromi", email_nick
    assert_equal "kuromi@sanrio.com", email

    email_str = "kuromi <kuromi@sanrio.com>"
    email_hash = ControllerHelper.parse_email(email_str)
    email = email_hash[ControllerHelper::EMAIL_STR]
    email_nick = email_hash[ControllerHelper::EMAIL_NICK_STR]
    assert_equal "kuromi", email_nick

    email_str = "<kuromi@sanrio.com>"
    email_hash = ControllerHelper.parse_email(email_str)
    email = email_hash[ControllerHelper::EMAIL_STR]
    email_nick = email_hash[ControllerHelper::EMAIL_NICK_STR]
    assert_nil email_nick
    assert_equal "kuromi@sanrio.com", email

    email_str = "kuromi@sanrio.com"
    email_hash = ControllerHelper.parse_email(email_str)
    email = email_hash[ControllerHelper::EMAIL_STR]
    email_nick = email_hash[ControllerHelper::EMAIL_NICK_STR]
    assert_nil email_nick
    assert_equal "kuromi@sanrio.com", email
  end # end test "parse email to get nick and email

  test "pick up pii without colon" do
    receiver_pii_str = "kuromi@sanrio.com"
    receiver_nick_str = "kurochan"
    input_str = "#{receiver_pii_str} #{receiver_nick_str} lawson12 hakusan12 ;you're evil!;"
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    assert_equal receiver_pii_str, meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    assert_equal receiver_nick_str, meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK]
  end # end test "pick up pii without colon" do

  test "send meant.it from webpage results in sender anon or login id" do
    email_elem = inbound_emails(:nick_y_xxx_y_yyy_y_tags_y_sender_idable_inbound_email)
    common_code(email_elem, nil)
  end # end test "send meant.it from webpage results in sender anon or login id"

  test "no space in nick from email" do
    email = "hello kitty <hello_kitty@sanrio.com>"
    email_hash = ControllerHelper.parse_email(email)
    assert_equal "hello_kitty", email_hash[ControllerHelper::EMAIL_NICK_STR]
    assert_equal "hello_kitty@sanrio.com", email_hash[ControllerHelper::EMAIL_STR]
  end # end test "no space in nick from email"

  test "caps in input str pii" do
    orig_pii_str = "25===P0001"
    orig_message_str = "hello world"
    input_str = ":#{orig_pii_str} ;#{orig_message_str};"
    meantItInput_hash = ControllerHelper.parse_meant_it_input(input_str)
    message_str = meantItInput_hash[ControllerHelper::MEANT_IT_INPUT_MESSAGE]
    receiver_pii_str = meantItInput_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
   assert_equal orig_message_str.downcase, message_str
   assert_equal orig_pii_str.downcase, receiver_pii_str
  end # end test "caps in input str pii"

  test "anonymous sender from web page" do
    email_elem = inbound_emails(:anonymous_inbound_email_from_web_page)
    common_code(email_elem, nil)
  end # end test "anonymous sender from web page"

  test "auto entity domain" do
    email_elem = inbound_emails(:auto_entity_domain)
    common_code(email_elem, nil)
  end # end test "auto entity domain"

  test "sellable_pii" do
    # Test email_bill_entry created if sellable
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email)
    post :create, :inbound_email => email_elem.attributes
    # Get the new pii
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    pii_value = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    hk_pii = Pii.find_by_pii_value(pii_value)
    assert_equal(false, ControllerHelper.sellable_pii(hk_pii), "newly created pii is not sellable since no pii_property_set")
    # Now create the pii_property_set and fill in
    hk_pii.pii_property_set = PiiPropertySet.create
    assert_equal(false, ControllerHelper.sellable_pii(hk_pii), "pii with default pii_property_set is also not sellable since some attributes are nil")
    # Now fill in the necessary properties to make pii sellable
    hk_pii.pii_property_set.threshold = 15
    hk_pii.pii_property_set.status = StatusTypeValidator::STATUS_ACTIVE
    hk_pii.pii_property_set.save
    assert_equal(true, ControllerHelper.sellable_pii(hk_pii), "pii with pii_property that has required fields filled in is sellable")
    # Non active pii are not sellable
    hk_pii.pii_property_set.status = StatusTypeValidator::STATUS_INACTIVE
    hk_pii.pii_property_set.save
    assert_equal(false, ControllerHelper.sellable_pii(hk_pii), "pii with pii_property status set to inactive is not sellable")
    # Pii whose value is not marked by ENTITY_DOMAIN_MARKER are not sellable
    email_elem = inbound_emails(:nick_n_xxx_y_non_sellable_yyy_n_tags_y_currency_sender_idable_inbound_email)
    post :create, :inbound_email => email_elem.attributes
    hd_pii = Pii.find_by_pii_value("hello_doggy")
    hd_pii.pii_property_set = PiiPropertySet.create
    hd_pii.pii_property_set.threshold = 15
    hd_pii.pii_property_set.status = StatusTypeValidator::STATUS_ACTIVE
    assert_equal(false, ControllerHelper.sellable_pii(hd_pii), "pii with pii_value without ENTITY_DOMAIN_MARKER:#{Constants::ENTITY_DOMAIN_MARKER} is not sellable")
  end # end test "sellable_pii" do

  test "email_bill_entry value_type_value_uniq but no currency specified" do
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_no_currency_sender_idable_inbound_email)
    # Set the path so that the "from:" email is used
    # otherwise sender is anonymous
    @request.path = Constants::SENDGRID_PARSE_URL
    post :create, :inbound_email => email_elem.attributes
    # Get the new pii
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    pii_value = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    hk_pii = Pii.find_by_pii_value(pii_value)
    assert_equal(false, ControllerHelper.sellable_pii(hk_pii), "newly created pii is not sellable since no pii_property_set")
    # Now create pii_propery_set and fill in the 
    # necessary properties to make pii sellable
    hk_pii.pii_property_set = PiiPropertySet.create
    hk_pii.pii_property_set.threshold = 15
    hk_pii.pii_property_set.status = StatusTypeValidator::STATUS_ACTIVE
    hk_pii.pii_property_set.value_type = ValueTypeValidator::VALUE_TYPE_VALUE_UNIQ
    hk_pii.pii_property_set.save
    assert_equal(true, ControllerHelper.sellable_pii(hk_pii), "pii with appropriate fields filled in is sellable")
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_no_currency_sender_idable_inbound_email_buy)
    # Create a new mir by sending another mail
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # for new sender and the nick for destination
      ['Pii.count', 1], # for new sender
      ['Tag.count', 0], # Same tag, i.e., xxx of xxx@meant.it
      ['EndPointTagRel.count', 0],
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 1]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    # Check the value of email_bill_entry.qty
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    assert_equal(1, hk_pii_email_bill_entries[0].meant_it_rels.size)
    assert_equal(0.to_f, hk_pii_email_bill_entries[0].qty)
    # If a same email is resubmitted
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 0], # no new sender and the nick for destination
      ['Pii.count', 0], # no new sender
      ['Tag.count', 0], # Same tag, i.e., xxx of xxx@meant.it
      ['EndPointTagRel.count', 0],
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 0]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    assert_equal(1, hk_pii_email_bill_entries[0].meant_it_rels.size)
    src_ep_hash = ControllerHelper.parse_email(email_elem.from)
    src_ep_1 = src_ep_hash[ControllerHelper::EMAIL_STR]
    mir_src_pii = hk_pii_email_bill_entries[0].meant_it_rels[0].src_endpoint.pii
    assert_equal(src_ep_1, mir_src_pii.pii_value)
    assert_equal(0.to_f, hk_pii_email_bill_entries[0].qty)
    # If a different email is resubmitted
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_no_currency_sender_idable_inbound_email_buy2)
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # for new sender and the nick for destination
      ['Pii.count', 1], # for new sender
      ['Tag.count', 0], # Same tag, i.e., xxx of xxx@meant.it
      ['EndPointTagRel.count', 0],
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 0]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    assert_equal(2, hk_pii_email_bill_entries[0].meant_it_rels.size)
    src_ep_hash = ControllerHelper.parse_email(email_elem.from)
    src_ep_2 = src_ep_hash[ControllerHelper::EMAIL_STR]
    src_ep_arr = []
    hk_pii_email_bill_entries[0].meant_it_rels.each { |mir_elem|
      src_ep_arr.push(mir_elem.src_endpoint.pii.pii_value)
    } # end hk_pii_email_bill_entries[0].meant_it_rels.each ...
    assert_equal(true, src_ep_arr.include?(src_ep_1))
    assert_equal(true, src_ep_arr.include?(src_ep_2))
    assert_equal(0.to_f, hk_pii_email_bill_entries[0].qty)
  end # end test "email_bill_entry value_type_value_uniq but no currency specified" do

  test "email_bill_entry value_type_value_uniq" do
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email)
    # Set the path so that the "from:" email is used
    # otherwise sender is anonymous
    @request.path = Constants::SENDGRID_PARSE_URL
    post :create, :inbound_email => email_elem.attributes
    # Get the new pii
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    pii_value = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    hk_pii = Pii.find_by_pii_value(pii_value)
    assert_equal(false, ControllerHelper.sellable_pii(hk_pii), "newly created pii is not sellable since no pii_property_set")
    # Now create pii_propery_set and fill in the 
    # necessary properties to make pii sellable
    hk_pii.pii_property_set = PiiPropertySet.create
    hk_pii.pii_property_set.currency = "SGD"
    hk_pii.pii_property_set.threshold = 1500
    hk_pii.pii_property_set.status = StatusTypeValidator::STATUS_ACTIVE
    hk_pii.pii_property_set.value_type = ValueTypeValidator::VALUE_TYPE_VALUE_UNIQ
    hk_pii.pii_property_set.save
    assert_equal(true, ControllerHelper.sellable_pii(hk_pii), "pii with appropriate fields filled in is sellable")
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email_buy)
    # Create a new mir by sending another mail
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # for new sender and the nick for destination
      ['Pii.count', 1], # for new sender
      ['Tag.count', 1], # New tag, i.e., each price is a new tag
      ['EndPointTagRel.count', 1], # New tag to endpoint
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 1]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    # Check the value of email_bill_entry.qty
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    assert_equal(1, hk_pii_email_bill_entries[0].meant_it_rels.size)
    sum_currency = ControllerHelper.sum_currency_in_str(input_str)
    sum_curr_code, sum_val = ControllerHelper.get_currency_code_and_val(sum_currency)
    assert_equal(sum_val.to_f, hk_pii_email_bill_entries[0].qty)
    assert_equal(sum_curr_code, hk_pii_email_bill_entries[0].currency)
    # If a same email is resubmitted, but with different value!
    body_text = email_elem.body_text
    # Get pii and currency
    email_body_hash = ControllerHelper.parse_meant_it_input(body_text)
    pii_str = email_body_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    curr_arr = ControllerHelper.get_currency_arr_from_str(body_text)
    # Just take one value
    new_curr_curr_code, new_curr_curr_val = ControllerHelper.get_currency_code_and_val(curr_arr[0])
    new_curr_f = new_curr_curr_val.to_f + 1.0
    new_curr_str = "#{new_curr_curr_code}#{new_curr_f}"
    email_elem.body_text = ":#{pii_str} #{new_curr_str}"
    p "new email_elem.body_text:#{email_elem.body_text}"
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 0], # no new sender and the nick for destination
      ['Pii.count', 0], # no new sender
      ['Tag.count', 1], # One more tag, i.e., the new curr value
      ['EndPointTagRel.count', 1], # One more tag => one more EndPointTagRel
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 0] # No new bill
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    # Still one entry since the sender is same 
    # and value_type is VALUE_TYPE_VALUE_UNIQ
    assert_equal(1, hk_pii_email_bill_entries[0].meant_it_rels.size)
    src_ep_hash = ControllerHelper.parse_email(email_elem.from)
    src_ep_1 = src_ep_hash[ControllerHelper::EMAIL_STR]
    mir_src_pii = hk_pii_email_bill_entries[0].meant_it_rels[0].src_endpoint.pii
    assert_equal(src_ep_1, mir_src_pii.pii_value)
    # The newer value will be used
    assert_equal(new_curr_f, hk_pii_email_bill_entries[0].qty)
    assert_equal(new_curr_curr_code, hk_pii_email_bill_entries[0].currency)
    # If a different email is resubmitted
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email_buy2)
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # for new sender and the nick for destination
      ['Pii.count', 1], # for new sender
      ['Tag.count', 1], # New tag because of new currency
      ['EndPointTagRel.count', 1],
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 0]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    # Increase in mirs in email_bill_entry because sender is different
    assert_equal(2, hk_pii_email_bill_entries[0].meant_it_rels.size)
    src_ep_hash = ControllerHelper.parse_email(email_elem.from)
    src_ep_2 = src_ep_hash[ControllerHelper::EMAIL_STR]
    src_ep_arr = []
    hk_pii_email_bill_entries[0].meant_it_rels.each { |mir_elem|
      src_ep_arr.push(mir_elem.src_endpoint.pii.pii_value)
    } # end hk_pii_email_bill_entries[0].meant_it_rels.each ...
    assert_equal(true, src_ep_arr.include?(src_ep_1))
    assert_equal(true, src_ep_arr.include?(src_ep_2))
    new_curr_2_str = ControllerHelper.sum_currency_in_str("#{email_elem.body_text} #{new_curr_str}")
    new_curr_2_curr_code, new_curr_2_curr_val = ControllerHelper.get_currency_code_and_val(new_curr_2_str)
    assert_equal(new_curr_2_curr_val.to_f, hk_pii_email_bill_entries[0].qty)
    assert_equal(new_curr_2_curr_code, hk_pii_email_bill_entries[0].currency)
  end # end test "email_bill_entry value_type_value_uniq" do

  test "email_bill_entry value_type_count_uniq" do
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email)
    # Set the path so that the "from:" email is used
    # otherwise sender is anonymous
    @request.path = Constants::SENDGRID_PARSE_URL
    post :create, :inbound_email => email_elem.attributes
    # Get the new pii
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    pii_value = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    hk_pii = Pii.find_by_pii_value(pii_value)
    assert_equal(false, ControllerHelper.sellable_pii(hk_pii), "newly created pii is not sellable since no pii_property_set")
    # Now create pii_propery_set and fill in the 
    # necessary properties to make pii sellable
    hk_pii.pii_property_set = PiiPropertySet.create
    hk_pii.pii_property_set.currency = nil
    hk_pii.pii_property_set.threshold = 1500
    hk_pii.pii_property_set.status = StatusTypeValidator::STATUS_ACTIVE
    hk_pii.pii_property_set.value_type = ValueTypeValidator::VALUE_TYPE_COUNT_UNIQ
    hk_pii.pii_property_set.save
    assert_equal(true, ControllerHelper.sellable_pii(hk_pii), "pii with appropriate fields filled in is sellable")
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email_buy)
    # Create a new mir by sending another mail
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # for new sender and the nick for destination
      ['Pii.count', 1], # for new sender
      ['Tag.count', 1], # New tag, i.e., each price is a new tag
      ['EndPointTagRel.count', 1], # New tag to endpoint
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 1]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    # Check the value of email_bill_entry.qty
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    assert_equal(1, hk_pii_email_bill_entries[0].meant_it_rels.size)
    assert_equal(1.to_f, hk_pii_email_bill_entries[0].qty)
    assert_nil(hk_pii_email_bill_entries[0].currency)
    # If a same email is resubmitted, but with different value!
    body_text = email_elem.body_text
    # Get pii and currency
    email_body_hash = ControllerHelper.parse_meant_it_input(body_text)
    pii_str = email_body_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    curr_arr = ControllerHelper.get_currency_arr_from_str(body_text)
    # Just take one value
    new_curr_curr_code, new_curr_curr_val = ControllerHelper.get_currency_code_and_val(curr_arr[0])
    new_curr_f = new_curr_curr_val.to_f + 1.0
    new_curr_str = "#{new_curr_curr_code}#{new_curr_f}"
    email_elem.body_text = ":#{pii_str} #{new_curr_str}"
    p "new email_elem.body_text:#{email_elem.body_text}"
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 0], # no new sender and the nick for destination
      ['Pii.count', 0], # no new sender
      ['Tag.count', 1], # One more tag, i.e., the new curr value
      ['EndPointTagRel.count', 1], # One more tag => one more EndPointTagRel
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 0] # No new bill
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    # Still one entry since the sender is same 
    # and value_type is VALUE_TYPE_VALUE_UNIQ
    assert_equal(1, hk_pii_email_bill_entries[0].meant_it_rels.size)
    src_ep_hash = ControllerHelper.parse_email(email_elem.from)
    src_ep_1 = src_ep_hash[ControllerHelper::EMAIL_STR]
    mir_src_pii = hk_pii_email_bill_entries[0].meant_it_rels[0].src_endpoint.pii
    assert_equal(src_ep_1, mir_src_pii.pii_value)
    # Count is still one since sender is the same
    assert_equal(1.to_f, hk_pii_email_bill_entries[0].qty)
    assert_nil(hk_pii_email_bill_entries[0].currency)
    # If a different email is resubmitted
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email_buy2)
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # for new sender and the nick for destination
      ['Pii.count', 1], # for new sender
      ['Tag.count', 1], # New tag because of new currency
      ['EndPointTagRel.count', 1],
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 0]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    # Increase in mirs in email_bill_entry because sender is different
    assert_equal(2, hk_pii_email_bill_entries[0].meant_it_rels.size)
    src_ep_hash = ControllerHelper.parse_email(email_elem.from)
    src_ep_2 = src_ep_hash[ControllerHelper::EMAIL_STR]
    src_ep_arr = []
    hk_pii_email_bill_entries[0].meant_it_rels.each { |mir_elem|
      src_ep_arr.push(mir_elem.src_endpoint.pii.pii_value)
    } # end hk_pii_email_bill_entries[0].meant_it_rels.each ...
    assert_equal(true, src_ep_arr.include?(src_ep_1))
    assert_equal(true, src_ep_arr.include?(src_ep_2))
    new_curr_2_str = ControllerHelper.sum_currency_in_str("#{email_elem.body_text} #{new_curr_str}")
    new_curr_2_curr_code, new_curr_2_curr_val = ControllerHelper.get_currency_code_and_val(new_curr_2_str)
    # The new count is two because the new inbound_email is from different sender
    assert_equal(2.to_f, hk_pii_email_bill_entries[0].qty)
    assert_nil(hk_pii_email_bill_entries[0].currency)
  end # end test "email_bill_entry value_type_count_uniq" do

  test "email_bill_entry value_type_value" do
    sum_thus_far_curr_val = 0
    sum_thus_far_curr_code = nil
    sum_thus_far_str = nil
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email)
    # Set the path so that the "from:" email is used
    # otherwise sender is anonymous
    @request.path = Constants::SENDGRID_PARSE_URL
    post :create, :inbound_email => email_elem.attributes
    # Get the new pii
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    pii_value = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    hk_pii = Pii.find_by_pii_value(pii_value)
    assert_equal(false, ControllerHelper.sellable_pii(hk_pii), "newly created pii is not sellable since no pii_property_set")
    # Now create pii_propery_set and fill in the 
    # necessary properties to make pii sellable
    hk_pii.pii_property_set = PiiPropertySet.create
    hk_pii.pii_property_set.currency = "SGD"
    hk_pii.pii_property_set.threshold = 1500
    hk_pii.pii_property_set.status = StatusTypeValidator::STATUS_ACTIVE
    hk_pii.pii_property_set.value_type = ValueTypeValidator::VALUE_TYPE_VALUE
    hk_pii.pii_property_set.save
    assert_equal(true, ControllerHelper.sellable_pii(hk_pii), "pii with appropriate fields filled in is sellable")
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email_buy)
    # Create a new mir by sending another mail
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # for new sender and the nick for destination
      ['Pii.count', 1], # for new sender
      ['Tag.count', 1], # New tag, i.e., each price is a new tag
      ['EndPointTagRel.count', 1], # New tag to endpoint
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 1]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    # Check the value of email_bill_entry.qty
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    assert_equal(1, hk_pii_email_bill_entries[0].meant_it_rels.size)
    sum_thus_far_str = ControllerHelper.sum_currency_in_str(input_str)
    sum_thus_far_curr_code, sum_thus_far_curr_val = ControllerHelper.get_currency_code_and_val(sum_thus_far_str)
    assert_equal(sum_thus_far_curr_val.to_f, hk_pii_email_bill_entries[0].qty)
    assert_equal(sum_thus_far_curr_code, hk_pii_email_bill_entries[0].currency)
    # If a same email is resubmitted, but with different value!
    body_text = email_elem.body_text
    # Get pii and currency
    email_body_hash = ControllerHelper.parse_meant_it_input(body_text)
    pii_str = email_body_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    curr_arr = ControllerHelper.get_currency_arr_from_str(body_text)
    # Just take one value
    new_curr_curr_code, new_curr_curr_val = ControllerHelper.get_currency_code_and_val(curr_arr[0])
    new_curr_f = new_curr_curr_val.to_f + 1.0
    new_curr_str = "#{new_curr_curr_code}#{new_curr_f}"
    email_elem.body_text = ":#{pii_str} #{new_curr_str}"
    p "new email_elem.body_text:#{email_elem.body_text}"
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 0], # no new sender and the nick for destination
      ['Pii.count', 0], # no new sender
      ['Tag.count', 1], # One more tag, i.e., the new curr value
      ['EndPointTagRel.count', 1], # One more tag => one more EndPointTagRel
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 0] # No new bill
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    # Add one entry even tho' the sender is same 
    # since value_type is VALUE_TYPE_VALUE
    assert_equal(2, hk_pii_email_bill_entries[0].meant_it_rels.size)
    src_ep_hash = ControllerHelper.parse_email(email_elem.from)
    src_ep_1 = src_ep_hash[ControllerHelper::EMAIL_STR]
    mir_src_pii = hk_pii_email_bill_entries[0].meant_it_rels[0].src_endpoint.pii
    assert_equal(src_ep_1, mir_src_pii.pii_value)
    # The sum of first email and second email value will be used
    sum_thus_far_curr_val += new_curr_f
    assert_equal(sum_thus_far_curr_val, hk_pii_email_bill_entries[0].qty)
    # Increase in the number of mirs
    assert_equal(2, hk_pii_email_bill_entries[0].meant_it_rels.size)
    # The currency code of first email and second email value are the same
    assert_equal(sum_thus_far_curr_code, new_curr_curr_code)
    assert_equal(new_curr_curr_code, hk_pii_email_bill_entries[0].currency)
    # If a different email is resubmitted
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email_buy2)
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # for new sender and the nick for destination
      ['Pii.count', 1], # for new sender
      ['Tag.count', 1], # New tag because of new currency
      ['EndPointTagRel.count', 1],
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 0]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    # Increase in mirs in email_bill_entry because sender is different
    assert_equal(3, hk_pii_email_bill_entries[0].meant_it_rels.size)
    src_ep_hash = ControllerHelper.parse_email(email_elem.from)
    src_ep_2 = src_ep_hash[ControllerHelper::EMAIL_STR]
    src_ep_arr = []
    hk_pii_email_bill_entries[0].meant_it_rels.each { |mir_elem|
      src_ep_arr.push(mir_elem.src_endpoint.pii.pii_value)
    } # end hk_pii_email_bill_entries[0].meant_it_rels.each ...
    assert_equal(true, src_ep_arr.include?(src_ep_1))
    assert_equal(true, src_ep_arr.include?(src_ep_2))
    new_curr_2_str = ControllerHelper.sum_currency_in_str("#{email_elem.body_text}")
    new_curr_2_curr_code, new_curr_2_curr_val = ControllerHelper.get_currency_code_and_val(new_curr_2_str)
    sum_thus_far_curr_val += new_curr_2_curr_val
    assert_equal(sum_thus_far_curr_val.to_f, hk_pii_email_bill_entries[0].qty)
    assert_equal(new_curr_2_curr_code, hk_pii_email_bill_entries[0].currency)
  end # end test "email_bill_entry value_type_value" do

  test "email_bill_entry value_type_count" do
    sum_thus_far_curr_val = 0
    sum_thus_far_curr_code = nil
    sum_thus_far_str = nil
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email)
    # Set the path so that the "from:" email is used
    # otherwise sender is anonymous
    @request.path = Constants::SENDGRID_PARSE_URL
    post :create, :inbound_email => email_elem.attributes
    # Get the new pii
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    pii_value = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    hk_pii = Pii.find_by_pii_value(pii_value)
    assert_equal(false, ControllerHelper.sellable_pii(hk_pii), "newly created pii is not sellable since no pii_property_set")
    # Now create pii_propery_set and fill in the 
    # necessary properties to make pii sellable
    hk_pii.pii_property_set = PiiPropertySet.create
    hk_pii.pii_property_set.currency = nil
    hk_pii.pii_property_set.threshold = 1500
    hk_pii.pii_property_set.status = StatusTypeValidator::STATUS_ACTIVE
    hk_pii.pii_property_set.value_type = ValueTypeValidator::VALUE_TYPE_COUNT
    hk_pii.pii_property_set.save
    assert_equal(true, ControllerHelper.sellable_pii(hk_pii), "pii with appropriate fields filled in is sellable")
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email_buy)
    # Create a new mir by sending another mail
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # for new sender and the nick for destination
      ['Pii.count', 1], # for new sender
      ['Tag.count', 1], # New tag, i.e., each price is a new tag
      ['EndPointTagRel.count', 1], # New tag to endpoint
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 1]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    # Check the value of email_bill_entry.qty
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    assert_equal(1, hk_pii_email_bill_entries[0].meant_it_rels.size)
    sum_thus_far_str = ControllerHelper.sum_currency_in_str(input_str)
    sum_thus_far_curr_code, sum_thus_far_curr_val = ControllerHelper.get_currency_code_and_val(sum_thus_far_str)
    assert_equal(1.to_f, hk_pii_email_bill_entries[0].qty)
    assert_nil(hk_pii_email_bill_entries[0].currency)
    # If a same email is resubmitted, but with different value!
    body_text = email_elem.body_text
    # Get pii and currency
    email_body_hash = ControllerHelper.parse_meant_it_input(body_text)
    pii_str = email_body_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    curr_arr = ControllerHelper.get_currency_arr_from_str(body_text)
    # Just take one value
    new_curr_curr_code, new_curr_curr_val = ControllerHelper.get_currency_code_and_val(curr_arr[0])
    new_curr_f = new_curr_curr_val.to_f + 1.0
    new_curr_str = "#{new_curr_curr_code}#{new_curr_f}"
    email_elem.body_text = ":#{pii_str} #{new_curr_str}"
    p "new email_elem.body_text:#{email_elem.body_text}"
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 0], # no new sender and the nick for destination
      ['Pii.count', 0], # no new sender
      ['Tag.count', 1], # One more tag, i.e., the new curr value
      ['EndPointTagRel.count', 1], # One more tag => one more EndPointTagRel
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 0] # No new bill
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    # Add one entry even tho' the sender is same 
    # since value_type is VALUE_TYPE_VALUE
    assert_equal(2, hk_pii_email_bill_entries[0].meant_it_rels.size)
    src_ep_hash = ControllerHelper.parse_email(email_elem.from)
    src_ep_1 = src_ep_hash[ControllerHelper::EMAIL_STR]
    mir_src_pii = hk_pii_email_bill_entries[0].meant_it_rels[0].src_endpoint.pii
    assert_equal(src_ep_1, mir_src_pii.pii_value)
    # The sum is not important, only the count on meant_it_rels
    sum_thus_far_curr_val += new_curr_f
    assert_equal(2.to_f, hk_pii_email_bill_entries[0].qty)
    # Increase in the number of mirs
    assert_equal(2, hk_pii_email_bill_entries[0].meant_it_rels.size)
    # The currency code of first email and second email value are the same
    assert_equal(sum_thus_far_curr_code, new_curr_curr_code)
    assert_nil(hk_pii_email_bill_entries[0].currency)
    # If a different email is resubmitted
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email_buy2)
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # for new sender and the nick for destination
      ['Pii.count', 1], # for new sender
      ['Tag.count', 1], # New tag because of new currency
      ['EndPointTagRel.count', 1],
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 0]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    # Increase in mirs in email_bill_entry because sender is different
    assert_equal(3, hk_pii_email_bill_entries[0].meant_it_rels.size)
    src_ep_hash = ControllerHelper.parse_email(email_elem.from)
    src_ep_2 = src_ep_hash[ControllerHelper::EMAIL_STR]
    src_ep_arr = []
    hk_pii_email_bill_entries[0].meant_it_rels.each { |mir_elem|
      src_ep_arr.push(mir_elem.src_endpoint.pii.pii_value)
    } # end hk_pii_email_bill_entries[0].meant_it_rels.each ...
    assert_equal(true, src_ep_arr.include?(src_ep_1))
    assert_equal(true, src_ep_arr.include?(src_ep_2))
    new_curr_2_str = ControllerHelper.sum_currency_in_str("#{email_elem.body_text}")
    new_curr_2_curr_code, new_curr_2_curr_val = ControllerHelper.get_currency_code_and_val(new_curr_2_str)
    sum_thus_far_curr_val += new_curr_2_curr_val
    assert_equal(3.to_f, hk_pii_email_bill_entries[0].qty)
    assert_nil(hk_pii_email_bill_entries[0].currency)
  end # end test "email_bill_entry value_type_count" do

  # The currency in pii_property_set.threshold does not match
  # with the one in meant_it_rel, i.e., inbound_email
  test "email_bill_entry value_type_value_uniq mismatch with threshold currency" do
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email)
    # Set the path so that the "from:" email is used
    # otherwise sender is anonymous
    @request.path = Constants::SENDGRID_PARSE_URL
    post :create, :inbound_email => email_elem.attributes
    # Get the new pii
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    pii_value = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    hk_pii = Pii.find_by_pii_value(pii_value)
    # Now create pii_propery_set and fill in the 
    # necessary properties to make pii sellable
    hk_pii.pii_property_set = PiiPropertySet.create
    hk_pii.pii_property_set.threshold = 15
    hk_pii.pii_property_set.status = StatusTypeValidator::STATUS_ACTIVE
    hk_pii.pii_property_set.value_type = ValueTypeValidator::VALUE_TYPE_VALUE_UNIQ
    hk_pii.pii_property_set.save
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email_buy)
    exception = assert_raise(Exception) { 
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
   } # end assert_raise
   assert_not_nil(exception.message)
   assert_not_nil(exception.message.match(/does not match/))
  end # end test "email_bill_entry value_type_value_uniq mismatch with threshold currency" do

  test "get currency from str" do
    # Each inner array holds the msg and the expected currency arr
    msg_ok_arr = [
                  [ "hello 200 SGD230.00 kitty", ["SGD230.00"] ],
                  [ "hello 200 kitty SGD230.00", ["SGD230.00"] ],
                  [ "200 hello SGD230.00 kitty", ["SGD230.00"] ],
                  [ "SGD230.00 hello MYR100 kitty", ["SGD230.00", "MYR100"] ],
                  [ "SGD230.00 MYR100 hello kitty", ["SGD230.00", "MYR100"] ],
                  [ "SGD230.00 hello kitty MYR100", ["SGD230.00", "MYR100"] ],
                  [ "hello SGD230.00 kitty MYR100", ["SGD230.00", "MYR100"] ],
                  [ "hello SGD230.00 MYR100 kitty" , ["SGD230.00", "MYR100"] ],
                  [ "hello kitty SGD230.00 MYR100", ["SGD230.00", "MYR100"] ]
                 ]
    msg_ok_arr.each { |msg_arr_elem|
      currency_arr = ControllerHelper.get_currency_arr_from_str(msg_arr_elem[0])
      assert_equal(msg_arr_elem[1], currency_arr, "msg:#{msg_arr_elem[0]}")
    } # end msg_ok_arr.each ...
  end # end test "get currency from str" do

  test "sum currency in str" do
    # Errors when we don't convert
    msg_err_arr = [
                   "SGD300 hello MYR200"
                  ]
    msg_err_arr.each { |msg_elem|
      assert_raise(Exception, "msg:#{msg_elem}") {
        ControllerHelper.sum_currency_in_str(msg_elem)
      } # end assert_raise(Exception) do
    } # end msg_err_arr.each ...
    # No errros if we convert
    # CODE: Currently Exceptions are raised during conversion
    # because we have not implemented conversion table.
    msg_err_arr.each { |msg_elem|
      assert_raise(Exception, "msg:#{msg_elem}") {
        ControllerHelper.sum_currency_in_str(msg_elem, true)
      } # end assert_raise(Exception) do
    } # end msg_err_arr.each ...
    msg_ok_arr = [
                   ["SGD300 SGD200.35 hello", "SGD500.35"],
                   ["SGD300 hello SGD200.35", "SGD500.35"],
                   ["SGD300 hello SGD200.35 kitty SGD1.15", "SGD501.50"],
                   ["SGD300 hello kitty SGD200.35 SGD1.15", "SGD501.50"]
                  ]
    msg_ok_arr.each { |msg_ok_arr_elem|
      sum = ControllerHelper.sum_currency_in_str(msg_ok_arr_elem[0])
      assert_equal(msg_ok_arr_elem[1], sum, "msg:#{msg_ok_arr_elem[0]}")
    } # end msg_ok_arr.each ...
  end # end test "sum currency in str" do

  test "subtract currency in str" do
    # Errors when we don't convert
    msg_err_arr = [
                   ["SGD300 hello SGD200", "MYR5.55"]
                  ]
    msg_err_arr.each { |msg_arr_elem|
      assert_raise(Exception, "msg:#{msg_arr_elem.inspect}") {
        ControllerHelper.subtract_currency_in_str(msg_arr_elem[0], msg_arr_elem[1])
      } # end assert_raise(Exception) do
    } # end msg_err_arr.each ...
    # No errros if we convert
    # CODE: Currently Exceptions are raised during conversion
    # because we have not implemented conversion table.
    msg_err_arr.each { |msg_arr_elem|
      assert_raise(Exception, "msg:#{msg_arr_elem.inspect}") {
        ControllerHelper.subtract_currency_in_str(msg_arr_elem[0], msg_arr_elem[1], true)
      } # end assert_raise(Exception) do
    } # end msg_err_arr.each ...
    msg_ok_arr = [
                   ["SGD300 SGD200.35 hello", "SGD0.35", "SGD500.00"],
                   ["SGD300 hello SGD200.35", "SGD0.35", "SGD500.00"],
                   ["SGD300 hello SGD200.35 kitty SGD1.15", "SGD0.50", "SGD501.00"],
                   ["SGD300 hello kitty SGD200.35 SGD1.15", "hello SGD0.50 kitty SGD1.00", "SGD500.00"]
                  ]
    msg_ok_arr.each { |msg_ok_arr_elem|
      result = ControllerHelper.subtract_currency_in_str(msg_ok_arr_elem[0], msg_ok_arr_elem[1])
      assert_equal(msg_ok_arr_elem[2], result, "msg:#{msg_ok_arr_elem.inspect}")
    } # end msg_ok_arr.each ...
  end # end test "subtract currency in str" do

  test "threshold reached value_type_value" do
    # This is ripped from email_bill_entry value_type_value
    sum_thus_far_curr_val = 0
    sum_thus_far_curr_code = nil
    sum_thus_far_str = nil
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email)
    # Set the path so that the "from:" email is used
    # otherwise sender is anonymous
    @request.path = Constants::SENDGRID_PARSE_URL
    post :create, :inbound_email => email_elem.attributes
    # Get the new pii
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    pii_value = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    hk_pii = Pii.find_by_pii_value(pii_value)
    assert_equal(false, ControllerHelper.sellable_pii(hk_pii), "newly created pii is not sellable since no pii_property_set")
    # Now create pii_propery_set and fill in the 
    # necessary properties to make pii sellable
    hk_pii.pii_property_set = PiiPropertySet.create
    hk_pii.pii_property_set.currency = "SGD"
    # NOTE: We submit inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email_buy) 
    # twice with the second time we increase by 1 unit currency
    # so we adjust threshold to the sum so that 
    # threshold is exceeded after the 2nd buy
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email_buy)
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    threshold = ControllerHelper.sum_currency_in_str(input_str)
    threshold_curr_code, threshold_curr_val = ControllerHelper.get_currency_code_and_val(threshold)
    one_unit_currency = "#{threshold_curr_code}1"
    threshold = ControllerHelper.sum_currency_in_str("#{threshold} #{threshold} #{one_unit_currency}")
    threshold_curr_code, threshold_curr_val = ControllerHelper.get_currency_code_and_val(threshold)
    hk_pii.pii_property_set.threshold = threshold_curr_val
    hk_pii.pii_property_set.currency = threshold_curr_code
    hk_pii.pii_property_set.status = StatusTypeValidator::STATUS_ACTIVE
    hk_pii.pii_property_set.value_type = ValueTypeValidator::VALUE_TYPE_VALUE
    hk_pii.pii_property_set.save
    assert_equal(true, ControllerHelper.sellable_pii(hk_pii), "pii with appropriate fields filled in is sellable")
    # Create a new mir by sending another mail
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # for new sender and the nick for destination
      ['Pii.count', 1], # for new sender
      ['Tag.count', 1], # New tag, i.e., each price is a new tag
      ['EndPointTagRel.count', 1], # New tag to endpoint
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 1]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    # Check the value of email_bill_entry.qty
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    assert_equal(1, hk_pii_email_bill_entries[0].meant_it_rels.size)
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    sum_thus_far_str = ControllerHelper.sum_currency_in_str(input_str)
    sum_thus_far_curr_code, sum_thus_far_curr_val = ControllerHelper.get_currency_code_and_val(sum_thus_far_str)
    assert_equal(sum_thus_far_curr_val.to_f, hk_pii_email_bill_entries[0].qty)
    assert_equal(sum_thus_far_curr_code, hk_pii_email_bill_entries[0].currency)
    # Check threshold
    assert(sum_thus_far_curr_val.to_f < hk_pii_email_bill_entries[0].pii_property_set.threshold)
    assert_nil(hk_pii_email_bill_entries[0].ready_date)
    # If a same email is resubmitted, but with different value!
    body_text = email_elem.body_text
    # Get pii and currency
    email_body_hash = ControllerHelper.parse_meant_it_input(body_text)
    pii_str = email_body_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    curr_arr = ControllerHelper.get_currency_arr_from_str(body_text)
    # Just take one value
    new_curr_curr_code, new_curr_curr_val = ControllerHelper.get_currency_code_and_val(curr_arr[0])
    new_curr_f = new_curr_curr_val.to_f + 1.0
    new_curr_str = "#{new_curr_curr_code}#{new_curr_f}"
    email_elem.body_text = ":#{pii_str} #{new_curr_str}"
    p "new email_elem.body_text:#{email_elem.body_text}"
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 0], # no new sender and the nick for destination
      ['Pii.count', 0], # no new sender
      ['Tag.count', 1], # One more tag, i.e., the new curr value
      ['EndPointTagRel.count', 1], # One more tag => one more EndPointTagRel
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 0] # No new bill
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    # Add one entry even tho' the sender is same 
    # since value_type is VALUE_TYPE_VALUE
    assert_equal(2, hk_pii_email_bill_entries[0].meant_it_rels.size)
    src_ep_hash = ControllerHelper.parse_email(email_elem.from)
    src_ep_1 = src_ep_hash[ControllerHelper::EMAIL_STR]
    mir_src_pii = hk_pii_email_bill_entries[0].meant_it_rels[0].src_endpoint.pii
    assert_equal(src_ep_1, mir_src_pii.pii_value)
    # The sum of first email and second email value will be used
    sum_thus_far_curr_val += new_curr_f
    assert_equal(sum_thus_far_curr_val, hk_pii_email_bill_entries[0].qty)
    # Increase in the number of mirs
    assert_equal(2, hk_pii_email_bill_entries[0].meant_it_rels.size)
    # The currency code of first email and second email value are the same
    assert_equal(sum_thus_far_curr_code, new_curr_curr_code)
    assert_equal(new_curr_curr_code, hk_pii_email_bill_entries[0].currency)
    # Check threshold
p "!!!!!!sum_thus_far_curr_val:#{sum_thus_far_curr_val}"
p "!!!!!!hk_pii_email_bill_entries[0].pii_property_set.threshold:#{hk_pii_email_bill_entries[0].pii_property_set.threshold}"
    assert(hk_pii_email_bill_entries[0].pii_property_set.threshold, sum_thus_far_curr_val)
    assert_nil(hk_pii_email_bill_entries[0].ready_date)
    assert_equal(ControllerHelper.get_price_from_formula(hk_pii.pii_property_set.formula), hk_pii_email_bill_entries[0].price_final)
    assert_equal(hk_pii.pii_property_set.threshold, hk_pii_email_bill_entries[0].threshold_final)
    assert_equal(hk_pii.pii_property_set.currency, hk_pii_email_bill_entries[0].currency)
    # Check price_final, threshold_final
    # CODE201111 for VALUE_TYPE_VALUE, price_final is nil



    # If a different email is resubmitted
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email_buy2)
    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2], # for new sender and the nick for destination
      ['Pii.count', 1], # for new sender
      ['Tag.count', 1], # New tag because of new currency
      ['EndPointTagRel.count', 1],
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1], # We create a link from MeantItRel to Tag
      ['EmailBillEntry.count', 0]
    ]) do
      # Set the path so that the "from:" email is used
      # otherwise sender is anonymous
      @request.path = Constants::SENDGRID_PARSE_URL
      post :create, :inbound_email => email_elem.attributes
    end # end assert_differences
    hk_pii.reload
    hk_pii_email_bill_entries = hk_pii.pii_property_set.email_bill_entries
    assert_equal(1, hk_pii_email_bill_entries.size)
    # Increase in mirs in email_bill_entry because sender is different
    assert_equal(3, hk_pii_email_bill_entries[0].meant_it_rels.size)
    src_ep_hash = ControllerHelper.parse_email(email_elem.from)
    src_ep_2 = src_ep_hash[ControllerHelper::EMAIL_STR]
    src_ep_arr = []
    hk_pii_email_bill_entries[0].meant_it_rels.each { |mir_elem|
      src_ep_arr.push(mir_elem.src_endpoint.pii.pii_value)
    } # end hk_pii_email_bill_entries[0].meant_it_rels.each ...
    assert_equal(true, src_ep_arr.include?(src_ep_1))
    assert_equal(true, src_ep_arr.include?(src_ep_2))
    new_curr_2_str = ControllerHelper.sum_currency_in_str("#{email_elem.body_text}")
    new_curr_2_curr_code, new_curr_2_curr_val = ControllerHelper.get_currency_code_and_val(new_curr_2_str)
    sum_thus_far_curr_val += new_curr_2_curr_val
    assert_equal(sum_thus_far_curr_val.to_f, hk_pii_email_bill_entries[0].qty)
    assert_equal(new_curr_2_curr_code, hk_pii_email_bill_entries[0].currency)
    # email_bill_entry.ready_date
CODE20111115
    # Bill now returns nil for ONE_TIME
    # Bill now returns nil for RECUR
  end # end test "threshold reached value_type_value" do

  test "aaa" do
    # Test abuse of inbound_emails_200
    # i.e., REMOTE_ADDR don't match
 
    # Test ib not inbound_emails_200, and logged in with id
    # meantItRel created should have pii as logged in id

    # Test find_any relationship
    # nick :xxx
    # :xxx :xxx
    # :xxx nick
    # nick nick
    # nick
    # :xxx
    # xxx
    # tag msg
  end
end
