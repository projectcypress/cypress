require 'test_helper'
require 'api_test'

class VendorsControllerTest < ActionController::TestCase
  include ApiTest

  setup do
    @vendor = FactoryBot.create(:vendor_with_points_of_contact)
    FactoryBot.create(:admin_user)
    FactoryBot.create(:atl_user)
    FactoryBot.create(:user_user)
    FactoryBot.create(:other_user)
    @vendor_user = FactoryBot.create(:vendor_user)
    add_user_to_vendor(@vendor_user, @vendor)
  end

  test 'should get index' do
    for_each_logged_in_user([ADMIN, ATL, USER, VENDOR, OTHER_VENDOR]) do
      get :index
      assert_response :success
      assert assigns(:vendors)
    end
  end

  test 'should get show' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, params: { id: @vendor.id }
      assert_response :success, "#{@user.email} should  have acces to vendor "
      assert assigns(:vendor)
      assert assigns(:products)
    end
  end

  test 'should restrict access to show' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :show, params: { id: @vendor.id }
      assert_response 401, "#{@user.email} should not have acces to vendor "
    end
  end

  test 'should get new' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      get :new
      assert_response :success
      assert assigns(:vendor)
    end
  end

  test 'should restrict access to  new' do
    for_each_logged_in_user([VENDOR]) do
      get :new
      assert_response 401
    end
  end

  # # # # # # #
  #   A P I   #
  # # # # # # #

  # JSON

  test 'should get index with json request' do
    for_each_logged_in_user([ADMIN, ATL, USER, VENDOR, OTHER_VENDOR]) do
      get :index, :format => :json
      assert_response :success, 'response should be OK on vendor index'
      assert assigns(:vendors)
      assert_not_nil JSON.parse(response.body)
    end
  end

  test 'should get show with json request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :json, :id => @vendor.id }
      assert_response :success, 'response should be OK on vendor show'
      assert assigns(:vendor)
      assert_not_nil JSON.parse(response.body)
    end
  end

  test 'should get error on show with invalid ID' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :json, :id => '123' }
      assert_response :not_found, 'response should be Not Found with invalid vendor ID'
      assert_equal 'Not Found', response.message
    end
  end

  test 'should get success on create vendor with json request' do
    vendor_index = 0
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      post :create, :params => { :format => :json, :vendor => { :name => "test vendor #{vendor_index}", :poc_attributes => { :name => 'test poc' } } }
      assert_response :created, 'response should be Created'
      assert_not_nil JSON.parse(response.body)
      assert_equal "test vendor #{vendor_index}", JSON.parse(response.body)['name']
      assert assigns(:vendor)
      assert response.headers['Location']
      get :show, :params => { :format => :json, :id => response.headers['Location'].split('/').last }
      assert_response :success, 'response should be OK on vendor show after create'
      vendor_index += 1
    end
  end

  test 'should get error on invalid create vendor with json request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      post :create, :params => { :format => :json, :vendor => { :name => @vendor.name, :poc_attributes => { :name => 'test poc' } } }
      assert_response :unprocessable_entity, 'response should be Unprocessable Entity'
      assert_has_json_errors JSON.parse(response.body), 'name' => ['Vendor name was already taken. Please choose another.']
    end
  end

  test 'should not post create with json request if no name' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      post :create, :params => { :format => :json, :vendor => { :poc_attributes => { :name => 'test poc' } } }
      assert_response 422, 'response should be Unprocessable Entity if no name given'
      assert_has_json_errors JSON.parse(response.body), 'name' => ['can\'t be blank']
    end
  end

  test 'should get success on update vendor with json request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      patch :update, :params => { :format => :json, :id => @vendor.id, :vendor => { :name => "Vendor #{rand}" } }
      assert_response :no_content, 'response should be No Content'
      assert_equal '', response.body
      assert assigns(:vendor)
    end
  end

  test 'should get error on invalid update vendor with json request' do
    vendor_taken_name = Vendor.create(:name => "Vendor #{rand}")
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      patch :update, :params => { :format => :json, :id => @vendor.id, :vendor => { :name => vendor_taken_name.name } }
      assert_response :unprocessable_entity, 'response should be Unprocessable Entity'
      assert_has_json_errors JSON.parse(response.body), 'name' => ['Vendor name was already taken. Please choose another.']
    end
  end

  test 'should get success on destroy vendor with json request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      vendor = create_vendor_with_owner
      delete :destroy, :params => { :format => :json, :id => vendor.id }
      assert_response :no_content, 'response should be No Content'
      assert_equal '', response.body
      get :show, :params => { :format => :json, :id => vendor.id }
      assert_response :not_found, 'response for get should be Not Found, because the Vendor should be destroyed'
    end
  end

  test 'should get error on invalid destroy vendor with json request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      delete :destroy, :params => { :format => :json, :id => '123' }
      assert_response :not_found, 'response should be Not Found with invalid Vendor ID'
    end
  end

  # test post json in middle of body
  test 'post json without setting format' do
    vendor_index = 0
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      request.headers['Content-Type'] = 'application/json'
      post :create, :params => { :vendor => { :name => "test vendor #{vendor_index}", :poc_attributes => { :name => 'test poc' } } }
      assert_equal 'text/html; charset=utf-8', response.headers['Content-Type']
      vendor_index += 1
    end
  end

  # XML

  test 'should get index with xml request' do
    for_each_logged_in_user([ADMIN, ATL, USER, VENDOR, OTHER_VENDOR]) do
      get :index, :format => :xml
      assert_response :success, 'response should be OK on vendor index'
      assert assigns(:vendors)
      assert_not_equal '', response.body
    end
  end

  test 'should get show with xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :xml, :id => @vendor.id }
      assert_response :success, 'response should be OK on vendor show'
      assert assigns(:vendor)
      assert_not_equal '', response.body
    end
  end

  test 'should get success on create vendor with xml request' do
    vendor_index = 0
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      post :create, :params => { :format => :xml, :vendor => { :name => "test vendor #{vendor_index}", :poc_attributes => { :name => 'test poc' } } }
      assert_response :created, 'response should be Created'
      assert_not_nil Hash.from_trusted_xml(response.body)
      assert_equal "test vendor #{vendor_index}", Hash.from_trusted_xml(response.body)['vendor']['name']
      assert assigns(:vendor)
      assert response.headers['Location']
      get :show, :params => { :format => :xml, :id => response.headers['Location'].split('/').last }
      assert_response :success, 'response should be OK on vendor show after create'
      vendor_index += 1
    end
  end

  test 'should get error on invalid create vendor with xml request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      post :create, :params => { :format => :xml, :vendor => { :name => @vendor.name, :poc_attributes => { :name => 'test poc' } } }
      assert_response :unprocessable_entity, 'response should be Unprocessable Entity'
      assert_has_xml_errors Hash.from_trusted_xml(response.body), 'name' => ['Vendor name was already taken. Please choose another.']
    end
  end

  test 'should not post create with xml request if no name' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      post :create, :params => { :format => :xml, :vendor => { :poc_attributes => { :name => 'test poc' } } }
      assert_response 422, 'response should be Unprocessable Entity if no name given'
      assert_has_xml_errors Hash.from_trusted_xml(response.body), 'name' => ['can\'t be blank']
    end
  end

  test 'should get success on destroy vendor with xml request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      vendor = create_vendor_with_owner
      delete :destroy, :params => { :format => :xml, :id => vendor.id }
      assert_response :no_content, 'response should be No Content'
      assert_equal '', response.body
      get :show, :params => { :format => :xml, :id => vendor.id }
      assert_response :not_found, 'response for get should be Not Found, because the Vendor should be destroyed'
    end
  end

  test 'should get success on update vendor with xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      patch :update, :params => { :format => :xml, :id => @vendor.id, :vendor => { :name => "Vendor #{rand}" } }
      assert_response :no_content, 'response should be No Content'
      assert_equal '', response.body
      assert assigns(:vendor)
    end
  end

  # # # # # # # # # # #
  #   H E L P E R S   #
  # # # # # # # # # # #

  def create_vendor_with_owner
    vendor = Vendor.new(:name => "Vendor #{rand}")
    @user.add_role :owner, vendor
    vendor.save!
    vendor
  end
end
