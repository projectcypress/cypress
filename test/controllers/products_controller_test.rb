require 'test_helper'
require 'api_test'

class ProductsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include ActiveJob::TestHelper
  include ApiTest

  setup do
    collection_fixtures('bundles', 'vendors', 'products', 'product_tests', 'tasks', 'users', 'measures', 'roles',
                        'records', 'patient_populations', 'health_data_standards_svs_value_sets', 'artifacts')
    @vendor = Vendor.find(EHR1)
    @first_product = @vendor.products.find('4f57a88a1d41c851eb000004')
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to index for unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :index, vendor_id: @vendor.id
      assert_response 401
    end
  end

  test 'should get new' do
    # do this for admin,atl,owner  -- need negative test for non access
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :new, vendor_id: @vendor.id, product_id: Product.new
      assert_response :success, "#{@user.email} should have access "
      assert_not_nil assigns(:product)
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to new for unauthorized users ' do
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      get :new, vendor_id: @vendor.id, product_id: Product.new
      assert_response 401
    end
  end

  test 'should get edit' do
    # do this for admin, atl and user:owner -- need negative test for users that
    # do not have access
    pd = Product.new(vendor: @vendor.id, name: "p_#{rand}", c1_test: true, measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'], bundle_id: '4fdb62e01d41c820f6000001')
    pd.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :edit, id: pd.id
      assert_response :success, "#{@user.email} should have access "
      assert_not_nil assigns(:product)
      assert_not_nil assigns(:selected_measure_ids)
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to edit for unauthorized users ' do
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      get :edit, id: @first_product.id
      assert_response 401
    end
  end

  test 'should destroy' do
    # do this for admin, atl and user:owner -- need negative test for users that
    # do not have access
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      pt = Product.new(vendor: @vendor.id, name: "p_#{rand}", c1_test: true, measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'], bundle_id: '4fdb62e01d41c820f6000001')
      pt.save!
      get :destroy, id: pt.id
      assert_response :redirect
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to delete for unauthorized users ' do
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      get :destroy, id: @first_product.id
      assert_response 401
    end
  end

  test 'should get show' do
    # do this for all users - need negative test for users that do not have access
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, id: @first_product.id, vendor_id: @vendor.id
      assert_response :success, "#{@user.email} should have access "
      assert_not_nil assigns(:product)
    end
  end
  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to show for unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :show, id: @first_product.id, vendor_id: @vendor.id
      assert_response 401
    end
  end

  test 'should create' do
    # do this for admin,atl,user:owner -- need negative test for non access
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, vendor_id: @vendor.id, product: { name: "test_product_#{rand}", c1_test: true, bundle_id: '4fdb62e01d41c820f6000001',
                                                      measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'] }
      assert_response 302, "#{@user.email} should have access #{response.status}"
      assert_not_nil assigns(:product)
    end
  end
  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to create for unauthorized users ' do
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      post :create, vendor_id: @vendor.id, product: { name: 'test_product', c1_test: true,
                                                      measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'] }
      assert_response 401
    end
  end

  test 'should be able to update measures' do
    # do this for admin,atl,user:owner -- need negative test for non access
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      ids = %w(40280381-4BE2-53B3-014C-0F589C1A1C39)
      pt = Product.new(vendor: @vendor.id, name: "p_#{rand}", c1_test: true, measure_ids: ids, bundle_id: '4fdb62e01d41c820f6000001')
      ids.each do |mid|
        pt.product_tests.build({ name: 'test_#{mid}',
                                 measure_ids: [mid] }, MeasureTest).save!
      end
      pt.save!
      assert_equal ids.sort, pt.measure_ids.sort, 'product should have same measure ids'

      new_ids = ['40280381-4B9A-3825-014B-C1A59E160733']
      pt.attributes[:measure_ids] = new_ids
      put :update, id: pt.id, product: pt.attributes
      pt.reload
      assert_response :redirect, "#{@user.email} should have access #{response.status}"
      assert_equal new_ids.sort, pt.measure_ids.sort
    end
  end

  test 'should be able to restrict access to update unauthorized users ' do
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      ids = %w(8A4D92B2-3887-5DF3-0139-0D01C6626E46 8A4D92B2-3887-5DF3-0139-0D08A4BE7BE6)
      pt = Product.new(vendor: @vendor.id, name: "test_product_#{rand}", c1_test: true, measure_ids: ids, bundle_id: '4fdb62e01d41c820f6000001')
      ids.each do |mid|
        pt.product_tests.build({ name: 'test_#{mid}',
                                 measure_ids: [mid] }, MeasureTest).save!
      end
      pt.save!
      assert_equal ids, pt.measure_ids, 'product should have same measure ids'

      new_ids = ['8A4D92B2-397A-48D2-0139-B0DC53B034A7']
      put :update, id: pt.id, product: pt.attributes, product_test: { measure_ids: new_ids }
      assert_response 401
    end
  end

  test 'should not crash without a bundle installed' do
    Bundle.all.destroy
    for_each_logged_in_user([ADMIN]) do
      get :new, vendor_id: @vendor.id
      assert_response :success, 'new product page should not error when no bundles'
    end
  end

  # checklist test

  test 'edit product name should not change checklist test' do
    product = create_product_with_checklist_test(['40280381-4BE2-53B3-014C-0F589C1A1C39'])
    old_checklist_test = product.product_tests.checklist_tests.first
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      product.attributes['name'] = "my product new name #{rand}"
      put :update, id: product.id, product: product.attributes
      assert product.product_tests.checklist_tests.first == old_checklist_test
    end
  end

  test 'removing measure test used in checklist test should change measure used in checklist test' do
    product = create_product_with_checklist_test(['40280381-4BE2-53B3-014C-0F589C1A1C39'])
    old_checklist_test = product.product_tests.checklist_tests.find_by(name: 'c1 visual')
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      product.attributes['measure_ids'] = ['40280381-4B9A-3825-014B-C1A59E160733']
      put :update, id: product.id, product: product.attributes
      assert_not_equal old_checklist_test, product.product_tests.checklist_tests.first
    end
  end

  # helper for checklist test tests
  def create_product_with_checklist_test(measure_ids)
    pt = Product.new(vendor: @vendor, name: "p_#{rand}", c1_test: true, measure_ids: measure_ids,
                     bundle_id: '4fdb62e01d41c820f6000001')
    pt.product_tests.build({ name: 'my_measure_test', measure_ids: measure_ids }, MeasureTest)
    pt.save!
    pt.add_checklist_test
    pt
  end

  # report

  test 'should generate a report' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :report, :format => :format_does_not_matter, :vendor_id => @vendor.id, :id => @first_product.id
      assert_response :success, "#{@user.email} should have access "
    end
  end

  test 'should restrict access to report to unauthorized users' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :report, vendor_id: @vendor.id, id: @first_product.id
      assert_response 401
    end
  end

  test 'should not generate a report if invalid product_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      product = Product.find('4f57a88a1d41c851eb000004')
      get :report, vendor_id: product.vendor.id, id: 'bad_id'
      assert_response 404, 'response should be Unprocessable Entity on report if bad id'
      assert_equal 'Not Found', response.message
    end
  end

  test 'should not generate a PDF report if invalid vendor_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      product = Product.find('4f57a88a1d41c851eb000004')
      get :report, vendor_id: 'bad_id', id: product.id
      assert_response 404, 'response should be Unprocessable Entity on report if bad id'
      assert_equal 'Not Found', response.message
    end
  end

  # patients

  test 'should get zip file of patients' do
    product = Product.find('4f57a88a1d41c851eb000004')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      perform_enqueued_jobs do
        product_test = product.product_tests.build({ name: "mtest #{rand}", measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'] }, MeasureTest)
        product_test.save!
        get :patients, :format => :format_does_not_matter, :vendor_id => product.vendor.id, :id => product.id
        assert_response 200, 'response should be OK for patients'
        assert_equal 'application/zip', response.headers['Content-Type']
      end
    end
  end

  test 'should not get zip file of patients if invalid product_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :patients, vendor_id: Product.find('4f57a88a1d41c851eb000004').vendor.id, id: 'bad_id'
      assert_response 404, 'response should be Unprocessable Entity on report if bad id'
      assert_equal 'Not Found', response.message
    end
  end

  test 'should not get zip file of patients if invalid vendor_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :patients, vendor_id: 'bad_id', id: '4f57a88a1d41c851eb000004'
      assert_response 404, 'response should be Unprocessable Entity on report if bad id'
      assert_equal 'Not Found', response.message
    end
  end

  # # # # # # #
  #   A P I   #
  # # # # # # #

  # JSON

  test 'should get index with json request' do
    vendor = Vendor.find('4f57a8791d41c851eb000002')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :format => :json, :vendor_id => vendor.id
      assert_response 200, 'response should be OK on product index'
      response_products = JSON.parse(response.body)
      assert_equal vendor.products.count, response_products.count, 'response body should have all products for vendor'
      response_products.each do |response_product|
        assert_has_product_attributes response_product
      end
    end
  end

  # note product show is independant of vendor_id
  test 'should get show with json request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :json, :id => '4f57a88a1d41c851eb000004'
      assert_response 200, 'response should be OK on product show'
      json_response = JSON.parse(response.body)
      assert_not_empty json_response
      assert_has_product_attributes json_response
    end
  end

  test 'should post create with json request' do
    vendor = Vendor.find('4f57a8791d41c851eb000002')
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, :format => :json, :vendor_id => vendor.id, :product => { name: "Product JSON post #{rand}", c1_test: true,
                                                                             measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'],
                                                                             bundle_id: '4fdb62e01d41c820f6000001' }
      assert_response 201, 'response should be Created on product create'
      assert response.location.end_with?(product_path(vendor.products.order_by(created_at: 'desc').first)),
             'response location should be product show'
    end
  end

  test 'should get destroy with json request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      pd = Product.new(vendor: @vendor.id, name: "p_#{rand}", c1_test: true, measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'],
                       bundle_id: '4fdb62e01d41c820f6000001')
      pd.save!
      delete :destroy, :format => :json, :id => pd.id
      assert_response 204, 'response should be No Content on product destroy'
      assert_equal '', response.body
      get :show, :format => :json, :id => pd.id
      assert_response 404, 'response should be Not Found because product should be destroyed'
    end
  end

  test 'should create checklist test on product create when c1 is selected' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      product_name = "my product name #{rand}"
      post :create, :format => :json, :vendor_id => '4f57a8791d41c851eb000002', :product => { name: product_name, c1_test: true,
                                                                                              measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'],
                                                                                              bundle_id:   '4fdb62e01d41c820f6000001' }
      product = Product.find_by(name: product_name)
      assert product.product_tests.checklist_tests.any?
    end
  end

  # XML

  test 'should get index with xml request' do
    vendor = Vendor.find('4f57a8791d41c851eb000002')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :format => :xml, :vendor_id => vendor.id
      assert_response 200, 'response should be OK on product index'
      response_products = Hash.from_trusted_xml(response.body)
      assert response_products['products']
      assert_equal vendor.products.count, response_products['products']['products'].count, 'response body should have all products for vendor'
    end
  end

  # note product show is independant of vendor_id
  test 'should get show with xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :xml, :id => '4f57a88a1d41c851eb000004'
      assert_response 200, 'response should be OK on product show'
      assert_not_empty Hash.from_trusted_xml(response.body)
    end
  end

  test 'should post create with xml request' do
    vendor = Vendor.find('4f57a8791d41c851eb000002')
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, :format => :xml, :vendor_id => vendor.id, :product => { name: "Product JSON post #{rand}", c1_test: true,
                                                                            measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'],
                                                                            bundle_id: '4fdb62e01d41c820f6000001' }
      assert_response 201, 'response should be Created on product create'
      assert response.location.end_with?(product_path(vendor.products.order_by(created_at: 'desc').first)),
             'response location should be product show'
    end
  end

  test 'should get destroy with xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      pd = Product.new(vendor: @vendor.id, name: "p_#{rand}", c1_test: true, measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'],
                       bundle_id: '4fdb62e01d41c820f6000001')
      pd.save!
      delete :destroy, :format => :xml, :id => pd.id
      assert_response 204, 'response should be No Content on product destroy'
      assert_equal '', response.body
      get :show, :format => :xml, :id => pd.id
      assert_response 404, 'response should be Not Found because product should be destroyed'
    end
  end

  # Unsuccessful Requests

  test 'should not get index with json request with bad vendor id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :format => :json, :vendor_id => 'bad_id'
      assert_response_not_found_and_empty_body response
    end
  end

  test 'should not post create with json request with bad vendor id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, :format => :json, :vendor_id => 'bad id', :product => { name: "Product JSON post #{rand}", c1_test: true,
                                                                            measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'],
                                                                            bundle_id: '4fdb62e01d41c820f6000001' }
      assert_response_not_found_and_empty_body response
    end
  end

  test 'should not post create with json request with no name' do
    vendor = Vendor.find('4f57a8791d41c851eb000002')
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, :format => :json, :vendor_id => vendor.id, :product => { c1_test: true, bundle_id: '4fdb62e01d41c820f6000001',
                                                                             measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'] }
      assert_response 422, 'response should be Unprocessable Entity on product create with no name'
      assert_has_json_errors JSON.parse(response.body), 'name' => ['can\'t be blank']
    end
  end

  test 'should not post create with json request with invalid measure ids' do
    vendor = Vendor.find('4f57a8791d41c851eb000002')
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, :format => :json, :vendor_id => vendor.id, :product => { name: "Product JSON post #{rand}", c1_test: true,
                                                                             measure_ids: ['invalid_measure_id'],
                                                                             bundle_id: '4fdb62e01d41c820f6000001' }
      assert_response 422, 'response should be Unprocessable Entity on product create'
      assert_has_json_errors JSON.parse(response.body), 'measure_ids' => ['must be valid hqmf ids']
    end
  end

  test 'should not post create with xml request with invalid measure ids' do
    vendor = Vendor.find('4f57a8791d41c851eb000002')
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, :format => :xml, :vendor_id => vendor.id, :product => { name: "Product JSON post #{rand}", c1_test: true,
                                                                            measure_ids: ['invalid_measure_id'],
                                                                            bundle_id: '4fdb62e01d41c820f6000001' }
      assert_response 422, 'response should be Unprocessable Entity on product create'
      assert_has_xml_errors Hash.from_trusted_xml(response.body), 'measure_ids' => ['must be valid hqmf ids']
    end
  end

  test 'should not post create with json request with no or empty measure ids' do
    vendor = Vendor.find('4f57a8791d41c851eb000002')
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, :format => :json, :vendor_id => vendor.id, :product => { name: "Product JSON post #{rand}", c1_test: true,
                                                                             bundle_id: '4fdb62e01d41c820f6000001' }
      assert_response 422, 'response should be Unprocessable Entity on product create with no measure_ids'
      assert_has_json_errors JSON.parse(response.body), 'measure_ids' => ['must select at least one']
      post :create, :format => :json, :vendor_id => vendor.id, :product => { name: "Product JSON post #{rand}", c1_test: true, measure_ids: [],
                                                                             bundle_id: '4fdb62e01d41c820f6000001' }
      assert_response 422, 'response should be Unprocessable Entity on product create with empty measure_ids'
      assert_has_json_errors JSON.parse(response.body), 'measure_ids' => ['must select at least one']
    end
  end

  test 'should strip trailing whitespace from name on create' do
    # do this for admin,atl,user:owner -- need negative test for non access
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      name = "test_product_#{rand}"
      post :create, vendor_id: @vendor.id, product: { name: "#{name} ", c1_test: true, bundle_id: '4fdb62e01d41c820f6000001',
                                                      measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'] }
      assert_equal name, assigns(:product)[:name], 'Product did not strip trailing whitespace from name on create'
    end
  end

  test 'should strip trailing whitespace from name on update' do
    product = create_product_with_checklist_test(['40280381-4BE2-53B3-014C-0F589C1A1C39'])
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      name = "p_#{rand}"
      product.name = "#{name} "
      put :update, id: product.id, product: product.attributes
      assert_equal name, assigns(:product)[:name], 'Product did not strip trailing whitespace from name on update'
    end
  end

  # # # # # # # # # # #
  #   H E L P E R S   #
  # # # # # # # # # # #

  def assert_response_not_found_and_empty_body(response)
    assert_response 404, 'response should be Not Found if bad id given'
    assert_equal 'Not Found', response.message
  end

  def assert_has_product_attributes(hash)
    assert_has_attributes(hash, %w(name description randomize_records duplicate_records links), %w(self product_tests patients))
  end
end
