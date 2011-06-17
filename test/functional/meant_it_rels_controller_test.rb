require 'test_helper'

class MeantItRelsControllerTest < ActionController::TestCase
  setup do
    @meant_it_rel = meant_it_rels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:meant_it_rels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create meant_it_rel" do
    assert_difference('MeantItRel.count') do
      post :create, :meant_it_rel => @meant_it_rel.attributes
    end

    assert_redirected_to meant_it_rel_path(assigns(:meant_it_rel))
  end

  test "should show meant_it_rel" do
    get :show, :id => @meant_it_rel.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @meant_it_rel.to_param
    assert_response :success
  end

  test "should update meant_it_rel" do
    put :update, :id => @meant_it_rel.to_param, :meant_it_rel => @meant_it_rel.attributes
    assert_redirected_to meant_it_rel_path(assigns(:meant_it_rel))
  end

  test "should destroy meant_it_rel" do
    assert_difference('MeantItRel.count', -1) do
      delete :destroy, :id => @meant_it_rel.to_param
    end

    assert_redirected_to meant_it_rels_path
  end
end
