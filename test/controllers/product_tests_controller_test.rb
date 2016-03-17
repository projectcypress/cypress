require 'test_helper'
class ProductTestsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include ActiveJob::TestHelper

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'users', 'roles', 'bundles', 'measures')
    @vendor = Vendor.find(EHR1)
    @first_product = @vendor.products.first
    @first_test = @first_product.product_tests.first
  end

  # test 'should get index' do
  #   for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
  #     get :index, product_id: @first_product.id
  #     assert_response :success, "#{@user.email} should have access "
  #     assert_not_nil assigns(:product_tests)
  #     assert_not_nil assigns(:product)
  #   end
  # end

  # test 'should restrict access to product test index' do
  #   for_each_logged_in_user([OTHER_VENDOR]) do
  #     get :index, product_id: @first_product.id
  #     assert_response 401
  #   end
  # end

  # test 'should get show' do
  #   # do this for all users
  #   for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
  #     my_product = @first_product.product_tests.first
  #     get :show, id: my_product.id, product_id: @first_product.id
  #     assert_response :success, "#{@user.email} should have access "
  #     assert_not_nil assigns(:product_test)
  #   end
  # end

  # test 'should restrict access to product test show' do
  #   for_each_logged_in_user([OTHER_VENDOR]) do
  #     my_product = @first_test
  #     get :show, id: my_product.id, product_id: @first_product.id
  #     assert_response 401
  #   end
  # end

  # test 'should get show measure test' do
  #   mt = Product.first.product_tests.build({ name: 'mtest', measure_ids: ['0001'] }, MeasureTest)
  #   mt.save!
  #   for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
  #     get :show, id: mt.id, product_id: mt.product.id
  #     assert_response :success, "#{@user.email} should have access "
  #     assert_not_nil assigns(:product_test)
  #   end
  # end

  # test 'should restrict access to product measure test show' do
  #   mt = Product.first.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
  #   mt.save!
  #   for_each_logged_in_user([OTHER_VENDOR]) do
  #     get :show, id: mt.id, product_id: mt.product.id
  #     assert_response 401
  #   end
  # end

  test 'should be able to download zip file of patients' do
    product = Product.create!(vendor: Vendor.first, name: 'Product 1', c1_test: true, bundle_id: '4fdb62e01d41c820f6000001',
                              measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'])
    product_test = product.product_tests.build({ name: 'mtest', measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'],
                                                 bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    product_test.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :patients, :id => product_test.id, :format => :format_does_not_matter
      assert_response :success, "#{@user.email} should have access. response was #{response.status}"
      assert_not_nil assigns(:product_test)
      assert_equal 'application/zip', response.headers['Content-Type']
    end
  end

  test 'should restrict access to download zip' do
    product_test = Product.first.product_tests.build({ name: 'mtest', measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'],
                                                       bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    product_test.save!
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :patients, :id => product_test.id, :format => :format_does_not_matter
      assert_response 401
    end
  end

  test 'should not be able to download zip file of patients if invalid product_test id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :patients, :format => :format_does_not_matter, :id => 'bad_id'
      assert_response 404, 'response should be Not Found on patients if bad id'
      assert_equal '', response.body
    end
  end
  # need negative tests for user that does not have owner or vendor access
end
