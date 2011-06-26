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

  # Tests for source that is global id-able, i.e., email

  # nick (yes) :xxx (no) ;yyy; (*) bla (yes): sender (id-able source)
  test "should create inbound_email" do
    all_fixture_inbound_emails = InboundEmail.find(:all)
    p "all_fixture_inbound_emails.inspect:#{all_fixture_inbound_emails.inspect}"
    all_fixture_inbound_emails.each { |email_elem|

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
      assert_nil receiver_endPoint.pii

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

    } # end all_fixture_inbound_emails.each ...
    
  end # end test "should create inbound_email" do

  test "should create inbound_email but not sender endpoint" do
    # Send the same message twice
    # Same sender but different receiver, pii is increased by one
    # Different sender but same receiver, pii is specified, new receiver_endPoint but no new pii
  end # end test "should create inbound_email but not sender endpoint" do

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
end
