require 'test_helper'

class PiisControllerTest < ActionController::TestCase
  setup do
    @pii = piis(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:piis)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pii" do
    assert_difference('Pii.count') do
      post :create, :pii => @pii.attributes
    end

    assert_redirected_to pii_path(assigns(:pii))
  end

  test "should show pii" do
    get :show, :id => @pii.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @pii.to_param
    assert_response :success
  end

  test "should update pii" do
    put :update, :id => @pii.to_param, :pii => @pii.attributes
    assert_redirected_to pii_path(assigns(:pii))
  end

  test "should destroy pii" do
    assert_difference('Pii.count', -1) do
      delete :destroy, :id => @pii.to_param
    end

    assert_redirected_to piis_path
  end
end
