require 'test_helper'

class EntityDataControllerTest < ActionController::TestCase
  setup do
    @entity_datum = entity_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:entity_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create entity_datum" do
    assert_difference('EntityDatum.count') do
      post :create, :entity_datum => @entity_datum.attributes
    end

    assert_redirected_to entity_datum_path(assigns(:entity_datum))
  end

  test "should show entity_datum" do
    get :show, :id => @entity_datum.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @entity_datum.to_param
    assert_response :success
  end

  test "should update entity_datum" do
    put :update, :id => @entity_datum.to_param, :entity_datum => @entity_datum.attributes
    assert_redirected_to entity_datum_path(assigns(:entity_datum))
  end

  test "should destroy entity_datum" do
    assert_difference('EntityDatum.count', -1) do
      delete :destroy, :id => @entity_datum.to_param
    end

    assert_redirected_to entity_data_path
  end
end
