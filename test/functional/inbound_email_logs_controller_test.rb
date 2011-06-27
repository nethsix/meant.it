require 'test_helper'

class InboundEmailLogsControllerTest < ActionController::TestCase
  setup do
    @inbound_email_log = inbound_email_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:inbound_email_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create inbound_email_log" do
    assert_difference('InboundEmailLog.count') do
      post :create, :inbound_email_log => @inbound_email_log.attributes
    end

    assert_redirected_to inbound_email_log_path(assigns(:inbound_email_log))
  end

  test "should show inbound_email_log" do
    get :show, :id => @inbound_email_log.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @inbound_email_log.to_param
    assert_response :success
  end

  test "should update inbound_email_log" do
    put :update, :id => @inbound_email_log.to_param, :inbound_email_log => @inbound_email_log.attributes
    assert_redirected_to inbound_email_log_path(assigns(:inbound_email_log))
  end

  test "should destroy inbound_email_log" do
    assert_difference('InboundEmailLog.count', -1) do
      delete :destroy, :id => @inbound_email_log.to_param
    end

    assert_redirected_to inbound_email_logs_path
  end
end
