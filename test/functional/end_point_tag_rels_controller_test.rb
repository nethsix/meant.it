require 'test_helper'

class EndPointTagRelsControllerTest < ActionController::TestCase
  setup do
    @end_point_tag_rel = end_point_tag_rels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:end_point_tag_rels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create end_point_tag_rel" do
    assert_difference('EndPointTagRel.count') do
      post :create, :end_point_tag_rel => @end_point_tag_rel.attributes
    end

    assert_redirected_to end_point_tag_rel_path(assigns(:end_point_tag_rel))
  end

  test "should show end_point_tag_rel" do
    get :show, :id => @end_point_tag_rel.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @end_point_tag_rel.to_param
    assert_response :success
  end

  test "should update end_point_tag_rel" do
    put :update, :id => @end_point_tag_rel.to_param, :end_point_tag_rel => @end_point_tag_rel.attributes
    assert_redirected_to end_point_tag_rel_path(assigns(:end_point_tag_rel))
  end

  test "should destroy end_point_tag_rel" do
    assert_difference('EndPointTagRel.count', -1) do
      delete :destroy, :id => @end_point_tag_rel.to_param
    end

    assert_redirected_to end_point_tag_rels_path
  end
end
