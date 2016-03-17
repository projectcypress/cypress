require 'test_helper'
class VendorsControllerTest < ActionController::TestCase
  setup do
    collection_fixtures('vendors', 'products', 'users', 'roles')
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
      get :show, id: Vendor.find(EHR1).id
      assert_response :success, "#{@user.email} should  have acces to vendor "
      assert assigns(:vendor)
      assert assigns(:products)
    end
  end

  test 'should restrict access to show' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :show, id: Vendor.find(EHR1).id
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
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
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
      get :show, :format => :json, :id => Vendor.first.id
      assert_response :success, 'response should be OK on vendor show'
      assert assigns(:vendor)
      assert_not_nil JSON.parse(response.body)
    end
  end

  test 'should get error on show with invalid ID' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :json, :id => '123'
      assert_response :not_found, 'response should be Not Found with invalid vendor ID'
      assert_equal '', response.body
    end
  end

  test 'should get success on create vendor with json request' do
    vendor_index = 0
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      post :create, :format => :json, :vendor => { name: "test vendor #{vendor_index}", poc_attributes: { name: 'test poc' } }
      assert_response :created, 'response should be Created'
      assert_equal '', response.body
      assert assigns(:vendor)
      assert response.headers['Location']
      get :show, :format => :json, :id => response.headers['Location'].split('/').last
      assert_response :success, 'response should be OK on vendor show after create'
      vendor_index += 1
    end
  end

  test 'should get error on invalid create vendor with json request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      post :create, :format => :json, :vendor => { name: Vendor.first.name, poc_attributes: { name: 'test poc' } }
      assert_response :unprocessable_entity, 'response should be Unprocessable Entity'
      assert_not_nil response.body['errors']
    end
  end

  test 'should not post create with json request if no name' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      post :create, :format => :json, :vendor => { poc_attributes: { name: 'test poc' } }
      assert_response 400, 'response should be Bad Request if no name given'
      assert_equal '', response.body
    end
  end

  test 'should get success on update vendor with json request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      patch :update, :format => :json, :id => Vendor.first.id, :vendor => { name: 'test name' }
      assert_response :no_content, 'response should be No Content'
      assert_equal '', response.body
      assert assigns(:vendor)
    end
  end

  test 'should get error on invalid update vendor with json request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      patch :update, :format => :json, :id => Vendor.order_by(:id => :desc).first.id, :vendor => { name: Vendor.order_by(:id => :desc).last.name }
      assert_response :unprocessable_entity, 'response should be Unprocessable Entity'
      assert_not_nil response.body['errors']
    end
  end

  test 'should get success on destroy vendor with json request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      vendor = Vendor.new(name: 'test_vendor')
      vendor.save
      delete :destroy, :format => :json, :id => vendor.id
      assert_response :no_content, 'response should be No Content'
      assert_equal '', response.body
      get :show, :format => :json, :id => vendor.id
      assert_response :not_found, 'response for get should be Not Found, because the Vendor should be destroyed'
    end
  end

  test 'should get error on invalid destroy vendor with json request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      delete :destroy, :format => :json, :id => '123'
      assert_response :not_found, 'response should be Not Found with invalid Vendor ID'
      assert_equal '', response.body
    end
  end

  # test post json in middle of body
  test 'post json without setting format' do
    vendor_index = 0
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      request.headers['Content-Type'] = 'application/json'
      post :create, vendor: { name: "test vendor #{vendor_index}", poc_attributes: { name: 'test poc' } }
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
      get :show, :format => :xml, :id => Vendor.first.id
      assert_response :success, 'response should be OK on vendor show'
      assert assigns(:vendor)
      assert_not_equal '', response.body
    end
  end

  test 'should get success on create vendor with xml request' do
    vendor_index = 0
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      post :create, :format => :xml, :vendor => { name: "test vendor #{vendor_index}", poc_attributes: { name: 'test poc' } }
      assert_response :created, 'response should be Created'
      assert_equal '', response.body
      assert assigns(:vendor)
      assert response.headers['Location']
      get :show, :format => :xml, :id => response.headers['Location'].split('/').last
      assert_response :success, 'response should be OK on vendor show after create'
      vendor_index += 1
    end
  end

  test 'should get error on invalid create vendor with xml request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      post :create, :format => :xml, :vendor => { name: Vendor.first.name, poc_attributes: { name: 'test poc' } }
      assert_response :unprocessable_entity, 'response should be Unprocessable Entity'
      assert_not_nil response.body['errors']
    end
  end

  test 'should not post create with xml request if no name' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      post :create, :format => :xml, :vendor => { poc_attributes: { name: 'test poc' } }
      assert_response 400, 'response should be Bad Request if no name given'
      assert_equal '', response.body
    end
  end

  test 'should get success on destroy vendor with xml request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      vendor = Vendor.new(name: 'test_vendor')
      vendor.save
      delete :destroy, :format => :xml, :id => vendor.id
      assert_response :no_content, 'response should be No Content'
      assert_equal '', response.body
      get :show, :format => :xml, :id => vendor.id
      assert_response :not_found, 'response for get should be Not Found, because the Vendor should be destroyed'
    end
  end

  test 'should get success on update vendor with xml request' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      patch :update, :format => :xml, :id => Vendor.first.id, :vendor => { name: 'test name' }
      assert_response :no_content, 'response should be No Content'
      assert_equal '', response.body
      assert assigns(:vendor)
    end
  end
end
