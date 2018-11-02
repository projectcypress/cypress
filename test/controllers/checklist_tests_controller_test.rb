require 'test_helper'
class ChecklistTestsControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  setup do
    FactoryBot.create(:admin_user)
    FactoryBot.create(:user_user)
    vendor_user = FactoryBot.create(:vendor_user)
    FactoryBot.create(:other_user)
    @user = FactoryBot.create(:atl_user)
    product = FactoryBot.create(:product_static_bundle)
    @vendor = product.vendor
    add_user_to_vendor(vendor_user, @vendor)
    @bundle = product.bundle
    @test = product.product_tests.create!({ name: 'c1 visual', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, ChecklistTest)
  end

  test 'should be able to view measure' do
    measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
    product = @vendor.products.create!(name: "my product #{rand}", c1_test: true, bundle_id: @bundle.id, measure_ids: measure_ids)
    product.product_tests.create!({ name: "my measure test #{rand}", measure_ids: measure_ids }, MeasureTest)
    checklist_test = product.product_tests.create!({ name: "my measure test #{rand}", measure_ids: measure_ids }, ChecklistTest)
    measure = checklist_test.measures.first

    # admin, atl, owner, and user should have access to view measure for checklist test
    for_each_logged_in_user([ADMIN, ATL, OWNER, USER]) do
      get :measure, params: { :id => checklist_test.id, :measure_id => measure.id, :format => :format_does_not_matter }
      assert_response :success, "#{@user.email} should have access. response was #{response.status}"
      assert_not_nil assigns(:measure)
      assert_not_nil assigns(:product_test)
    end

    # vendor and other vendor should not have access to view measure for checklist test
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      get :measure, :params => { :id => checklist_test.id, :measure_id => measure.id, :format => :format_does_not_matter }
      assert_response :unauthorized, "#{@user.email} should not have access. response was #{response.status}"
    end
  end
end
