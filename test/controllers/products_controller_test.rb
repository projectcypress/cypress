require 'test_helper'
class ProductsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('bundles', 'vendors', 'products', 'product_tests', 'tasks', 'users', 'measures')
    sign_in User.first
  end

  test 'should be able to update measures' do
    pt = Product.new(vendor: Vendor.first, name: 'test_product', c1_test: true)

    ids = %w('0001', '0002', '0003', '0004')
    ids.each do |mid|
      pt.product_tests.build({ name: 'test_#{mid}',
                               measure_ids: [mid],
                               bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest).save!
    end
    pt.save!
    assert_equal ids, pt.measure_ids, 'product should have same measure ids'

    new_ids = ['8A4D92B2-397A-48D2-0139-B0DC53B034A7']
    put :update, id: pt.id, product: pt.attributes, product_test: { measure_ids: new_ids }
    pt.reload
    assert_equal new_ids, pt.measure_ids
  end
end
