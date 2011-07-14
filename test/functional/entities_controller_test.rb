require 'test_helper'

class EntitiesControllerTest < ActionController::TestCase
  setup do
# We can't do this since we set attr_accessible only for a few fields
# We'll get 'WARNING: Can't mass-assign protected attributes: 
# property_document_id, created_at, updated_at, id, password_salt, 
# status, password_hash'
#    @entity = entities(:good_entity)
    good_entity_hash = { :login_name => "hello_kitty",
                         :password => "hello kitty" }
    post :create, :entity => good_entity_hash
    @entity = Entity.find_by_login_name(good_entity_hash[:login_name])
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:entities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create entity" do
    this_entity_hash = { :login_name => "kuromi_papa",
                         :password => "papa is evil" }
    assert_difference('Entity.count') do
      post :create, :entity => this_entity_hash
    end

    assert_redirected_to entity_path(assigns(:entity))
  end

  test "should show entity" do
    get :show, :id => @entity.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @entity.to_param
    assert_response :success
  end

  test "should update entity" do
    put :update, :id => @entity.to_param, :entity => { :login_name => @entity.login_name, :password => "new password" }
    assert_redirected_to entity_path(assigns(:entity))
  end

  test "should destroy entity" do
    assert_difference('Entity.count', -1) do
      delete :destroy, :id => @entity.to_param
    end

    assert_redirected_to entities_path
  end

  test "should create entity with property document id" do
    good_email_entity_hash = { :login_name => "gloomy@sanrio.com",
                               :password => "hello bear" }
    assert_differences([
        ['Entity.count', 1],
        ['EntityDatum.count', 1]
      ]) do
      post :create, :entity => good_email_entity_hash
    end
    
    new_entity = Entity.find_by_login_name(good_email_entity_hash[:login_name])
    assert_equal good_email_entity_hash[:login_name], new_entity.login_name
    property_document_id = new_entity.property_document_id
    assert_not_nil property_document_id
    new_person = EntityDatum.find property_document_id
    assert_not_nil new_person
    assert_equal good_email_entity_hash[:login_name], new_person.email
    assert_redirected_to entity_path(assigns(:entity))
  end # end test "should create entity with property document id"
end
