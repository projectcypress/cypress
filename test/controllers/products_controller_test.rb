require 'test_helper'
class ProductsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include ActiveJob::TestHelper

  setup do
    collection_fixtures('bundles', 'vendors', 'products', 'product_tests', 'tasks', 'users', 'measures', 'roles',
                        'records', 'patient_populations', 'health_data_standards_svs_value_sets', 'artifacts')
    @vendor = Vendor.find(EHR1)
    @first_product = @vendor.products.first
  end

  test 'should get index' do
    # do this for admin,atl,owner and vendor -- need negative test for non access
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, vendor_id: @vendor.id
      assert_response 200
    end
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
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :edit, id: @first_product.id
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
      pt = Product.new(vendor: @vendor.id, name: "p_#{rand}", c1_test: true)
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
      post :create, vendor_id: @vendor.id, product: { name: "test_product_#{rand}", c1_test: true, measure_ids: [Measure.first.id] }
      assert_response :success, "#{@user.email} should have access #{response.status}"
      assert_not_nil assigns(:product)
    end
  end
  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to create for unauthorized users ' do
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      post :create, vendor_id: @vendor.id, product: { name: 'test_product', c1_test: true, measure_ids: [Measure.first.id] }
      assert_response 401
    end
  end

  test 'should be able to update measures' do
    # do this for admin,atl,user:owner -- need negative test for non access
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      pt = Product.new(vendor: @vendor.id, name: "p_#{rand}", c1_test: true,
                       bundle_id: '4fdb62e01d41c820f6000001')

      ids = %w(0001, 0002, 0003, 0004)
      ids.each do |mid|
        pt.product_tests.build({ name: 'test_#{mid}',
                                 measure_ids: [mid] }, MeasureTest).save!
      end
      pt.save!
      assert_equal ids.sort, pt.measure_ids.sort, 'product should have same measure ids'

      new_ids = ['8A4D92B2-397A-48D2-0139-B0DC53B034A7']
      put :update, id: pt.id, product: pt.attributes, product_test: { measure_ids: new_ids }
      pt.reload
      assert_response :redirect, "#{@user.email} should have access #{response.status}"
      assert_equal new_ids.sort, pt.measure_ids.sort
    end
  end

  test 'should be able to restrict access to update unauthorized users ' do
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      pt = Product.new(vendor: @vendor.id, name: "test_product_#{rand}", c1_test: true,
                       bundle_id: '4fdb62e01d41c820f6000001')

      ids = %w('0001', '0002', '0003', '0004')
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

  # report

  test 'should generate a PDF report' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :report, :format => :format_does_not_matter, :vendor_id => @vendor.id, :id => @first_product.id
      assert_response :success, "#{@user.email} should have access "
      assert_equal 'application/pdf', response.headers['Content-Type']
    end
  end

  test 'should restrict access to PDF report to unauthorized users' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :report, vendor_id: @vendor.id, id: @first_product.id
      assert_response 401
    end
  end

  test 'should not generate a PDF report if invalid product_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      product = Product.first
      get :report, vendor_id: product.vendor.id, id: 'bad_id'
      assert_response 404, 'response should be Unprocessable Entity on report if bad id'
      assert_equal '', response.body
    end
  end

  test 'should not generate a PDF report if invalid vendor_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      product = Product.first
      get :report, vendor_id: 'bad_id', id: product.id
      assert_response 404, 'response should be Unprocessable Entity on report if bad id'
      assert_equal '', response.body
    end
  end

  # patients

  test 'should get zip file of patients' do
    product = Product.first
    perform_enqueued_jobs do
      product_test = product.product_tests.build({ name: 'mtest', measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'],
                                                   bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
      product_test.save!
      get :patients, :format => :format_does_not_matter, :vendor_id => product.vendor.id, :id => product.id
      assert_response 200, 'response should be OK for patients'
      assert_equal 'application/zip', response.headers['Content-Type']
    end
  end

  test 'should not get zip file of patients if invalid product_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :patients, vendor_id: Product.first.vendor.id, id: 'bad_id'
      assert_response 404, 'response should be Unprocessable Entity on report if bad id'
      assert_equal '', response.body
    end
  end

  test 'should not get zip file of patients if invalid vendor_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :patients, vendor_id: 'bad_id', id: Product.first.id
      assert_response 404, 'response should be Unprocessable Entity on report if bad id'
      assert_equal '', response.body
    end
  end

  # # # # # # #
  #   A P I   #
  # # # # # # #

  # JSON

  test 'should get index with json request' do
    vendor = Vendor.first
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :format => :json, :vendor_id => vendor.id
      assert_response 200, 'response should be OK on product index'
      response_products = JSON.parse(response.body)
      assert_equal vendor.products.count, response_products.count, 'response body should have all products for vendor'
      response_products.each do |response_product|
        assert response_product['product']
      end
    end
  end

  # note product show is independant of vendor_id
  test 'should get show with json request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :json, :id => Product.first.id
      assert_response 200, 'response should be OK on product show'
      assert_not_empty JSON.parse(response.body)
    end
  end

  # <-- Add create, update, and destroy

  # XML

  test 'should get index with xml request' do
    vendor = Vendor.first
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :format => :xml, :vendor_id => vendor.id
      assert_response 200, 'response should be OK on product index'
      response_products = Hash.from_trusted_xml(response.body)
      assert response_products['products']
      assert_equal vendor.products.count, response_products['products'].count, 'response body should have all products for vendor'
    end
  end

  # note product show is independant of vendor_id
  test 'should get show with xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :xml, :id => Product.first.id
      assert_response 200, 'response should be OK on product show'
      assert_not_empty Hash.from_trusted_xml(response.body)
    end
  end

  # <-- Add create, update, and destroy

  # Unsuccessful Requests

  test 'should not get index with json request with bad vendor id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :format => :json, :vendor_id => 'bad_id'
      assert_response_not_found_and_empty_body response
    end
  end

  # <-- Add create

  # # # # # # # # # # #
  #   H E L P E R S   #
  # # # # # # # # # # #

  def assert_response_not_found_and_empty_body(response)
    assert_response 404, 'response should be Not Found if bad id given'
    assert_equal '', response.body, 'response body should be empty for Not Found'
  end
end
