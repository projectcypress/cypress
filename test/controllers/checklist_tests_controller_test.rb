require 'test_helper'

class ChecklistTestsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include ActiveJob::TestHelper

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'users', 'roles', 'bundles', 'measures')
    @vendor = Vendor.find(EHR1)
    @product = @vendor.products.find('4f57a88a1d41c851eb000004')
    @test = @product.product_tests.find('4f58f8de1d41c851eb000478')
    @test['_type'] = MeasureTest # each measure test should have a _type of MeasureTest and cms_id
    @test['cms_id'] = 'CMS001'
    @test.save!
  end

  test 'should be able to view measure' do
    measure_ids = ['40280381-4B9A-3825-014B-C1A59E160733']
    product = @vendor.products.create!(name: "my product #{rand}", c1_test: true, bundle_id: '4fdb62e01d41c820f6000001', measure_ids: measure_ids)
    product.product_tests.create!({ name: "my measure test #{rand}", measure_ids: measure_ids }, MeasureTest)
    checklist_test = product.product_tests.create!({ name: "my measure test #{rand}", measure_ids: measure_ids }, ChecklistTest)
    measure = checklist_test.measures.first

    # admin, atl, owner, and user should have access to view measure for checklist test
    for_each_logged_in_user([ADMIN, ATL, OWNER, USER]) do
      get :measure, params: { :id => checklist_test.id, :measure_id => measure.id, :format => :format_does_not_matter }
      assert_response :success, "#{@user.email} should have access. response was #{response.status}"
      assert_not_nil assigns(:measure)
      assert_not_nil assigns(:product_test)
      # assert_equal 'application/zip', response.headers['Content-Type']
    end

    # vendor and other vendor should not have access to view measure for checklist test
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      get :measure, :params => { :id => checklist_test.id, :measure_id => measure.id, :format => :format_does_not_matter }
      assert_response :unauthorized, "#{@user.email} should not have access. response was #{response.status}"
    end
  end
end
