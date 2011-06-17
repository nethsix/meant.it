require 'test_helper'

class EntityEndPointRelsControllerTest < ActionController::TestCase
  setup do
    @entity_end_point_rel = entity_end_point_rels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:entity_end_point_rels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create entity_end_point_rel" do
    assert_difference('EntityEndPointRel.count') do
      post :create, :entity_end_point_rel => @entity_end_point_rel.attributes
    end

    assert_redirected_to entity_end_point_rel_path(assigns(:entity_end_point_rel))
  end

  test "should show entity_end_point_rel" do
    get :show, :id => @entity_end_point_rel.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @entity_end_point_rel.to_param
    assert_response :success
  end

  test "should update entity_end_point_rel" do
    put :update, :id => @entity_end_point_rel.to_param, :entity_end_point_rel => @entity_end_point_rel.attributes
    assert_redirected_to entity_end_point_rel_path(assigns(:entity_end_point_rel))
  end

  test "should destroy entity_end_point_rel" do
    assert_difference('EntityEndPointRel.count', -1) do
      delete :destroy, :id => @entity_end_point_rel.to_param
    end

    assert_redirected_to entity_end_point_rels_path
  end
end
