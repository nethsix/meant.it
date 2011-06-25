require 'test_helper'

class InboundEmailsControllerTest < ActionController::TestCase
  setup do
# To use inbound_emails() we need to use fixtures(?)
    @inbound_email = inbound_emails(:nick_y_xxx_n_yyy_y_tags_y_sender_idable_inbound_email)
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
      # Check that one InboundEmail is created
      # Check that two EndPoints are created
      assert_differences([
        ['InboundEmail.count', 1],
        ['EndPoint.count', 2],
        ['Pii.count', 1],
        ['Entity.count', 1],
        ]) do
      post :create, :inbound_email => email_elem.attributes
      end

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
      input_str = email_elem.subject
      input_str ||= email_elem.body_text
      meantItRel_hash = ControllerHelper.parse_meant_it_input(input_str)
      receiver_endPoint = EndPoint.find_by_creator_endpoint_id_and_nick(sender_endPoint.id, meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_NICK])
      assert_not_nil receiver_endPoint
      assert_nil receiver_endPoint.pii

      # Check receiver_endPoint tags
      tag_str_arr = meantItRel_hash[ControllerHelper::MEANT_IT_INPUT_TAGS]
      tagged_endPoints = EndPoint.tagged(tag_str_arr)
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
      message_type_str = ControllerHelper.parse_message_type_from_email_addr(email_elem.to)
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
      
    } # end all_fixture_inbound_emails.each ...
    
  end # end test "should create inbound_email nick_y_xxx_n_yyy_any_tags_y_sender_id-able" do

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
