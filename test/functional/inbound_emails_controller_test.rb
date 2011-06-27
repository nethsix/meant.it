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
        ['InboundEmail.count', 1],
        ['EndPoint.count', 2],
        ['Pii.count', 1+receiver_pii_count],
        ['Entity.count', 1],
        ['EntityDatum.count', 1],
        ['EntityEndPointRel.count', 1],
        ['Tag.count', non_exist_endpoint_tag_arr.size + non_exist_mood_tag_arr.size],
        ['EndPointTagRel.count', endpoint_tag_arr.size],
        ['MeantItRel.count', 1],
        ['MeantItMoodTagRel.count', 1],
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
      sender_endPoint = sender_pii.endPoint
      assert_not_nil sender_endPoint

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

  # nick (yes) :xxx (no) ;yyy; (*) bla (yes): sender (id-able source)
#12345     test "should create inbound_email" do
#12345       all_fixture_inbound_emails = InboundEmail.find(:all)
#12345       p "all_fixture_inbound_emails.inspect:#{all_fixture_inbound_emails.inspect}"
#12345       all_fixture_inbound_emails.each { |email_elem|
#12345         p "testing inbound_email.inspect:#{email_elem.inspect}"
#12345   
#12345         input_str = email_elem.subject
#12345         input_str ||= email_elem.body_text
#12345         meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
#12345         p "meantItRel_hash.inspect:#{meantItRel_hash.inspect}"
#12345         receiver_pii_count = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII].nil? ? 0 : 1
#12345         message_type_str = ControllerHelper.parse_message_type_from_email_addr(email_elem.to)
#12345   p "email_elem.to:#{email_elem.to}"
#12345   p "message_type_str:#{message_type_str}"
#12345         endpoint_tag_arr = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_TAGS].dup
#12345         p "BBBBBBBB #{email_elem.body_text} BBBBBBB endpoint_tag_arr:#{endpoint_tag_arr.inspect}"
#12345         # Check each tag for existance
#12345         non_exist_endpoint_tag_arr = []
#12345         endpoint_tag_arr.each { |tag_elem|
#12345           non_exist_endpoint_tag_arr << tag_elem if !Tag.exists?(:name => tag_elem)
#12345         }  # end input_tag_arr.each ...
#12345         mood_tag_arr = []
#12345         if message_type_str == MeantItMessageTypeValidator::MEANT_IT_MESSAGE_OTHER
#12345           # CODE!!!! Get mood tags using reasoner
#12345           # mood_tag_arr += ...
#12345         else
#12345           mood_tag_arr << message_type_str
#12345         end # end if message_type_str == MeantItMessageTypeValidator:: ...
#12345         p "mood_tag_arr:#{mood_tag_arr.inspect}"
#12345         non_exist_mood_tag_arr = []
#12345         mood_tag_arr.each { |tag_elem|
#12345           non_exist_mood_tag_arr << tag_elem if !Tag.exists?(:name => tag_elem)
#12345         }  # end mood_tag_arr.each ...
#12345         p "#AAAA non_exist_mood_tag_arr.inspect:#{non_exist_mood_tag_arr.inspect}"
#12345   
#12345         assert_differences([
#12345           ['InboundEmail.count', 1],
#12345           ['EndPoint.count', 2],
#12345           ['Pii.count', 1+receiver_pii_count],
#12345           ['Entity.count', 1],
#12345           ['EntityDatum.count', 1],
#12345           ['EntityEndPointRel.count', 1],
#12345           ['Tag.count', non_exist_endpoint_tag_arr.size + non_exist_mood_tag_arr.size],
#12345           ['EndPointTagRel.count', endpoint_tag_arr.size],
#12345           ['MeantItRel.count', 1],
#12345           ['MeantItMoodTagRel.count', 1],
#12345           ]) do
#12345           post :create, :inbound_email => email_elem.attributes
#12345         end
#12345   
#12345   p "MeantItMoodTagRel.count:#{MeantItMoodTagRel.count}"
#12345   p "MeantItMoodTagRel.all:#{MeantItMoodTagRel.all.inspect}"
#12345   
#12345         assert_redirected_to inbound_email_path(assigns(:inbound_email))
#12345   
#12345         # Check that email is created
#12345         inbound_email_from_db = InboundEmail.find_by_id(assigns(:inbound_email)["id"])
#12345         assert_not_nil inbound_email_from_db
#12345   
#12345         # Check that sender Pii
#12345         sender_pii = Pii.find_by_pii_value(email_elem.from)
#12345         assert_not_nil sender_pii
#12345   
#12345         # Check that sender EndPoint is created
#12345         sender_endPoint = sender_pii.endPoint
#12345         assert_not_nil sender_endPoint
#12345   
#12345         # Check that sender Entity is created
#12345         sender_entities = sender_endPoint.entities
#12345         assert_equal 1, sender_entities.size
#12345         sender_entity = sender_entities[0]
#12345         assert_not_nil sender_entity
#12345         # Check that sender Entity has the same pii
#12345         person = ControllerHelper.find_person_by_id(sender_entity.property_document_id)
#12345         assert_equal person.email, sender_pii.pii_value
#12345   
#12345         # Check that verification_type is email
#12345         assert_equal 1, sender_entity.entityEndPointRels.size
#12345         sender_entity_entityEndPointRel = sender_entity.entityEndPointRels[0]
#12345         assert_equal VerificationTypeValidator::VERIFICATION_TYPE_EMAIL, sender_entity_entityEndPointRel.verification_type
#12345   
#12345         # Check receiver_endPoint
#12345         receiver_endPoint = EndPoint.find_by_creator_endpoint_id_and_nick(sender_endPoint.id, meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK])
#12345         assert_not_nil receiver_endPoint
#12345         receiver_pii_str = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
#12345         if receiver_pii_str.nil? or receiver_pii_str.empty?
#12345           assert_nil receiver_endPoint.pii
#12345         else # else if !receiver_pii_str.nil? and !receiver_pii_str.empty?
#12345           assert_equal receiver_pii_str, receiver_endPoint.pii.pii_value
#12345         end # end # else if !receiver_pii_str.nil? and !receiver_pii_str.empty?
#12345   
#12345         # Check receiver_endPoint tags
#12345         p "meantItRel_hash.inspect:#{meantItRel_hash.inspect}"
#12345         tag_str_arr = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_TAGS]
#12345         p "tag_str_arr:#{tag_str_arr}"
#12345         tagged_endPoints = EndPoint.tagged(tag_str_arr)
#12345         p "tagged_endPoints.inspect:#{tagged_endPoints.inspect}"
#12345         tagged_endPoint = tagged_endPoints[0]
#12345         if tag_str_arr.nil? or tag_str_arr.empty?
#12345           assert_equal 0, tagged_endPoints.size
#12345         else
#12345           assert_equal 1, tagged_endPoints.size
#12345           assert_equal receiver_endPoint, tagged_endPoint
#12345         end # end if tag_str_arr.nil? ...
#12345       
#12345         # Check that MeantItRel is related to sender_endPoint and receiver_endPoint
#12345         assert_equal 1, sender_endPoint.srcMeantItRels.size
#12345         assert_equal receiver_endPoint.id, sender_endPoint.srcMeantItRels[0].dst_endpoint.id
#12345         assert_equal 1, receiver_endPoint.dstMeantItRels.size
#12345         assert_equal sender_endPoint.id, receiver_endPoint.dstMeantItRels[0].src_endpoint.id
#12345         assert_equal sender_endPoint.srcMeantItRels[0], receiver_endPoint.dstMeantItRels[0]
#12345         # Check that MeantItRel is related to email
#12345         assert_equal inbound_email_from_db.id, sender_endPoint.srcMeantItRels[0].inbound_email_id
#12345         assert_equal inbound_email_from_db.id, receiver_endPoint.dstMeantItRels[0].inbound_email_id
#12345         # Check meantIt type
#12345         assert_equal message_type_str, sender_endPoint.srcMeantItRels[0].message_type
#12345         # Check mood tags
#12345         if sender_endPoint.srcMeantItRels[0].message_type == MeantItMessageTypeValidator::MEANT_IT_MESSAGE_OTHER
#12345           # CODE!!!! Check with reaonser
#12345         else
#12345           meantItMoodTags = sender_endPoint.srcMeantItRels[0].tags
#12345           meantItMoodTag = meantItMoodTags[0]
#12345           assert_equal 1, meantItMoodTags.size
#12345           assert_equal MeantItMoodTagRel::MOOD_TAG_TYPE, meantItMoodTag.desc
#12345           assert_equal message_type_str, meantItMoodTag.name
#12345         end # end if sender_endPoint.srcMeantItRels[0].message_type == MeantItMessageTypeValidator::MEANT_IT_MESSAGE_OTHER
#12345         
#12345   p "#AAAAA MeantItMoodTagRel.count:#{MeantItMoodTagRel.count}"
#12345   p "#AAAAA MeantItMoodTagRel.all:#{MeantItMoodTagRel.all.inspect}"
#12345   
#12345       } # end all_fixture_inbound_emails.each ...
#12345       
#12345     end # end test "should create inbound_email" do

  test "should create inbound_email but not sender endpoint" do
    # CODE!!!
    # Send the same message twice
    # Same sender but different receiver, pii is increased by one
    # Different sender but same receiver, pii is specified, new receiver_endPoint but no new pii
    # Same sender same receiver but no pii
    # Add nick later to pii
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
    inbound_email_log_last = InboundEmailLog.last
    assert_match /#{first_inbound_email.to}/, inbound_email_log_last.params_txt
    assert_match /#{first_inbound_email.from}/, inbound_email_log_last.params_txt
    assert_match /#{first_inbound_email.body_text}/, inbound_email_log_last.params_txt
    assert_match /attachment/, inbound_email_log_last.error_msgs
    assert_match /attachment/, inbound_email_log_last.error_objs
    assert_response :success
  end # end test "should generate inbound_email_log but response success" do

  test "should generate error field in inbound_email but response success" do
    first_inbound_email = inbound_emails(:nick_n_xxx_y_yyy_y_tags_y_sender_idable_inbound_email)
    input_str = first_inbound_email.body_text
    meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
    receiver_pii = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
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
    # Change receiver_pii in body_text
    body_text = first_inbound_email.body_text
p "#AAAAAAA b4 body_text:#{body_text}"
    body_text.sub!(receiver_pii, "#{receiver_pii}_mutated") if !body_text.nil? and !receiver_pii.nil?
p "#AAAAAAA after body_text:#{body_text}"
    first_inbound_email.body_text = body_text

    assert_differences([
      ['InboundEmail.count', 1]
      ]) do
      # We accept that inbound_emails_200 will lead to action
      # create here.  We do this testing elsewhere.
      # See "/inbound_emails_200 should lead to create action and xml"
      @request.path = "/inbound_emails_200"
      post :create, :inbound_email => first_inbound_email.attributes
    end
    inbound_email_last = InboundEmail.last
    p "#### inbound_email_last #2:#{InboundEmail.last.body_text}"
    p "#### inbound_email_last #2:#{InboundEmail.last.error_msgs}"
    p "#### inbound_email_last #2:#{InboundEmail.last.error_objs}"
    assert_match /conflicts with receiver_pii 'pii:#{receiver_pii}/, inbound_email_last.error_msgs
    assert_match /OrderedHash/, inbound_email_last.error_objs
    assert_response :success
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
