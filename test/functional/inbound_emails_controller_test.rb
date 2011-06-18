require 'test_helper'

class InboundEmailsControllerTest < ActionController::TestCase
  setup do
    @inbound_email = inbound_emails(:one)
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

  test "should create inbound_email" do
    assert_difference('InboundEmail.count') do
      post :create, :inbound_email => @inbound_email.attributes
    end

    assert_redirected_to inbound_email_path(assigns(:inbound_email))
  end

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
