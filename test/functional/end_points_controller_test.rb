require 'test_helper'

class EndPointsControllerTest < ActionController::TestCase
  setup do
    @end_point = end_points(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:end_points)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create end_point" do
    assert_difference('EndPoint.count') do
      post :create, :end_point => @end_point.attributes
    end

    assert_redirected_to end_point_path(assigns(:end_point))
  end

  test "should show end_point" do
    get :show, :id => @end_point.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @end_point.to_param
    assert_response :success
  end

  test "should update end_point" do
    put :update, :id => @end_point.to_param, :end_point => @end_point.attributes
    assert_redirected_to end_point_path(assigns(:end_point))
  end

  test "should destroy end_point" do
    assert_difference('EndPoint.count', -1) do
      delete :destroy, :id => @end_point.to_param
    end

    assert_redirected_to end_points_path
  end
end
