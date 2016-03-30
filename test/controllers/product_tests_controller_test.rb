require 'test_helper'
require 'api_test'

class ProductTestsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include ActiveJob::TestHelper
  include ApiTest

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'users', 'roles', 'bundles', 'measures')
    @vendor = Vendor.find(EHR1)
    @product = @vendor.products.first
    @test = @product.product_tests.first
    @test['_type'] = MeasureTest # each measure test should have a _type of MeasureTest and cms_id
    @test['cms_id'] = 'CMS001'
    @test.save!
  end

  test 'should be able to download zip file of patients' do
    product = Product.create!(vendor: @vendor, name: 'Product 1', c1_test: true, bundle_id: '4fdb62e01d41c820f6000001',
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
    product_test = @product.product_tests.build({ name: 'mtest', measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'],
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

  # # # # # # #
  #   A P I   #
  # # # # # # #

  # json

  test 'should get index with json request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :format => :json, :product_id => @product.id
      assert_response 200, 'response should be OK on index'
      assert_equal @product.product_tests.count, JSON.parse(response.body).count
    end
  end

  test 'should get show with json request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :json, :product_id => @product.id, :id => @test.id
      assert_response 200, 'response should be OK on show'
      assert_has_product_test_attributes JSON.parse(response.body)
    end
  end

  test 'should get show with json request without product_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :json, :id => @test.id
      assert_response 200, 'response should be OK on show'
      assert_has_product_test_attributes JSON.parse(response.body)
    end
  end

  # xml

  test 'should get index with xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :format => :xml, :product_id => @product.id
      assert_response 200, 'response should be OK on index'
    end
  end

  test 'should get show with xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :xml, :product_id => @product.id, :id => @test.id
      assert_response 200, 'response should be OK on show'
    end
  end

  test 'should get show with xml request without product_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :xml, :id => @test.id
      assert_response 200, 'response should be OK on show'
    end
  end

  # unsuccessful requests

  test 'should restrict access to get index with json request' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :index, :format => :json, :product_id => @product.id
      assert_response 401, 'response should be Unauthorized on index'
    end
  end

  test 'should not get index with json request with bad product_id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :format => :json, :product_id => 'bad_id'
      assert_response 404, 'response should be Not Found on show with bad product_id'
    end
  end

  test 'should restrict access to get show with json request' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :show, :format => :xml, :product_id => @product.id, :id => @test.id
      assert_response 401, 'response should be Unauthorized on show'
    end
  end

  test 'should not get show with json request with bad id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :json, :product_id => @product.id, :id => 'bad_id'
      assert_response 404, 'response should be Not Found on show with bad product_test_id'
    end
  end

  # # # # # # # # # #
  #   H E L P E R   #
  # # # # # # # # # #

  def assert_has_product_test_attributes(hash)
    assert_has_attributes(hash, %w(name cms_id state type links), %w(self patients tasks))
  end
end
