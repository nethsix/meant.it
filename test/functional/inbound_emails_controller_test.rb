require 'test_helper'

class InboundEmailsControllerTest < ActionController::TestCase
  setup do
# To use inbound_emails() we need to use fixtures(?)
#    @inbound_email = inbound_emails(:nick_y_xxx_n_yyy_y_tags_y_sender_idable_inbound_email)
    @inbound_email = InboundEmail.first
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:inbound_emails)
  end

  test "should get new" do
    get :new
    assert_response :success
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
  end # end "nick_n_xxx_y_yyy_n_tags_n_sender_idable_inbound_email"

  def common_code(email_elem)
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

    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 2],
      ['Pii.count', 1+receiver_pii_count],
      ['Entity.count', 1],
      ['EntityDatum.count', 1],
      ['EntityEndPointRel.count', 1],
      ['Tag.count', non_exist_endpoint_tag_arr.size + non_exist_mood_tag_arr.size],
      ['EndPointTagRel.count', endpoint_tag_arr.size],
      ['MeantItRel.count', 1],
      ['MeantItMoodTagRel.count', 1]
      ]) do
      post :create, :inbound_email => email_elem.attributes
    end

p "MeantItMoodTagRel.count:#{MeantItMoodTagRel.count}"
p "MeantItMoodTagRel.all:#{MeantItMoodTagRel.all.inspect}"

    assert_redirected_to inbound_email_path(assigns(:inbound_email))

    # Check that email is created
    inbound_email_from_db = InboundEmail.find_by_id(assigns(:inbound_email)["id"])
    assert_not_nil inbound_email_from_db

    # Check that sender Pii
    sender_pii = Pii.find_by_pii_value(email_elem.from)
    assert_not_nil sender_pii

    # Check that sender EndPoint is created
#20110628a      sender_endPoint = sender_pii.endPoint
#20110628a      assert_not_nil sender_endPoint
    sender_endPoint_arr = sender_pii.endPoints
    assert_equal 1, sender_endPoint_arr.size
    sender_endPoint = sender_endPoint_arr[0]
    assert_equal email_elem.from, sender_endPoint.pii.pii_value

    # Check that sender Entity is created
    sender_entities = sender_endPoint.entities
    assert_equal 1, sender_entities.size
    sender_entity = sender_entities[0]
    assert_not_nil sender_entity
    # Check that sender Entity has the same pii
    person = ControllerHelper.find_person_by_id(sender_entity.property_document_id)
    assert_equal person.email, sender_pii.pii_value

    # Check that verification_type is email
    assert_equal 1, sender_entity.entityEndPointRels.size
    sender_entity_entityEndPointRel = sender_entity.entityEndPointRels[0]
    assert_equal VerificationTypeValidator::VERIFICATION_TYPE_EMAIL, sender_entity_entityEndPointRel.verification_type

    # Check receiver_endPoint
    receiver_endPoint = EndPoint.find_by_creator_endpoint_id_and_nick(sender_endPoint.id, meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK])
    assert_not_nil receiver_endPoint
    receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
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
      ['Entity.count', 1],
      ['Pii.count', 2],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200.xml"
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success

    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 0],
      ['Entity.count', 0],
      ['Pii.count', 0],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200"
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
      ['Entity.count', 1],
      ['Pii.count', 2],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200.xml"
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
      ['Entity.count', 0],
      ['Pii.count', 0],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200"
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
      ['Entity.count', 1],
      ['Pii.count', 2],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200.xml"
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
      ['Entity.count', 0],
      ['Pii.count', 0],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200"
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
      ['Entity.count', 1],
      ['Pii.count', 2],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200.xml"
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success

    # Use the same pii but no nick
    # Should reuse the receiver_endPoint with no nick tied to same pii

    assert_differences([
      ['InboundEmailLog.count', 0],
      ['InboundEmail.count', 1],
      ['EndPoint.count', 0],
      ['Entity.count', 0],
      ['Pii.count', 0],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200"
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
      ['Entity.count', 1],
      ['Pii.count', 2],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200.xml"
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
      ['Entity.count', 1],
      ['Pii.count', 1], # kuromi sender
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200"
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
      ['Entity.count', 1],
      ['Pii.count', 1],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200.xml"
      post :create, :inbound_email => first_inbound_email.attributes
    end
    assert_response :success
    kitty_pii = Pii.find_by_pii_value(first_inbound_email.from)
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
      ['Entity.count', 0],
      ['Pii.count', 1],
      ['MeantItRel.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200"
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
      @request.path = "/inbound_emails_200"
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
      @request.path = "/inbound_emails_200"
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
      @request.path = "/inbound_emails_200"
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
    get :show, :id => @inbound_email.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @inbound_email.to_param
    assert_response :success
  end

  test "should update inbound_email" do
    put :update, :id => @inbound_email.to_param, :inbound_email => @inbound_email.attributes
    assert_redirected_to inbound_email_path(assigns(:inbound_email))
  end

  test "should destroy inbound_email" do
    assert_difference('InboundEmail.count', -1) do
      delete :destroy, :id => @inbound_email.to_param
    end

    assert_redirected_to inbound_emails_path
  end

  test "inbound_emails_200 should lead to create action and xml" do
    assert_recognizes({:controller => "inbound_emails", :action => "create", :format => "xml"}, {:path => '/inbound_emails_200', :method => :post})
  end
end
