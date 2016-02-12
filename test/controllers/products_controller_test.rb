require 'test_helper'
class ProductsControllerTest < ActionController::TestCase
  setup do
    collection_fixtures('bundles', 'vendors', 'products', 'product_tests', 'tasks', 'users', 'measures', 'roles')
    @vendor = Vendor.find(EHR1)
    @first_product = @vendor.products.first
  end

  test 'should get index' do
    # do this for admin,atl,owner and vendor -- need negative test for non access
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, vendor_id: @vendor.id
      assert_response :redirect
    end
  end
  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to index for unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :index, vendor_id: @vendor.id
      assert_response 404
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
      assert_response 404
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
      assert_response 404
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
      assert_response 404
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
      assert_response 404
    end
  end

  test 'should create' do

    # do this for admin,atl,user:owner -- need negative test for non access
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, vendor_id: @vendor.id, product: { name: "test_product_#{rand}", c1_test: true, measure_ids: [Measure.first.id] }
      assert_response :redirect, "#{@user.email} should have access #{response.status}"
      assert_not_nil assigns(:product)
    end

  end
  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to create for unauthorized users ' do
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      post :create, vendor_id: @vendor.id, product: { name: 'test_product', c1_test: true, measure_ids: [Measure.first.id] }
      assert_response 404
    end
  end

  test 'should be able to update measures' do
    # do this for admin,atl,user:owner -- need negative test for non access
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      pt = Product.new(vendor: @vendor.id, name: "p_#{rand}", c1_test: true)

      ids = %w(0001, 0002, 0003, 0004)
      ids.each do |mid|
        pt.product_tests.build({ name: 'test_#{mid}',
                                 measure_ids: [mid],
                                 bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest).save!
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


  test 'should generate a PDF report' do
    get :download_pdf, vendor_id: Product.first.vendor, id: Product.first
    assert_response :success
    assert_equal 'application/pdf', response.headers['Content-Type']
  end


  test 'should be able to restrict access to update unauthorized users ' do
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      pt = Product.new(vendor: @vendor.id, name: "test_product_#{rand}", c1_test: true)

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
      assert_response 404
    end
  end

end
