require 'test_helper'

class ObjRelsControllerTest < ActionController::TestCase
  setup do
    @obj_rel = obj_rels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:obj_rels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create obj_rel" do
    assert_difference('ObjRel.count') do
      post :create, :obj_rel => @obj_rel.attributes
    end

    assert_redirected_to obj_rel_path(assigns(:obj_rel))
  end

  test "should show obj_rel" do
    get :show, :id => @obj_rel.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @obj_rel.to_param
    assert_response :success
  end

  test "should update obj_rel" do
    put :update, :id => @obj_rel.to_param, :obj_rel => @obj_rel.attributes
    assert_redirected_to obj_rel_path(assigns(:obj_rel))
  end

  test "should destroy obj_rel" do
    assert_difference('ObjRel.count', -1) do
      delete :destroy, :id => @obj_rel.to_param
    end

    assert_redirected_to obj_rels_path
  end
end
