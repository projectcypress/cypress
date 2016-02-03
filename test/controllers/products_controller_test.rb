require 'test_helper'
class ProductsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('bundles', 'vendors', 'products', 'product_tests', 'tasks', 'users', 'measures')
    sign_in User.first
  end

  def login_users_and_test(user_ids,&block)
      User.find([user_ids]).each do |user|
        sign_in user
        yield
      end
  end

  test 'should get index' do
    # do this for admin,atl,owner and vendor -- need negative test for non access
    login_users_and_test([]) do
      get :index, vendor_id: Vendor.first.id
      assert_response :redirect
    end
  end

  test 'should get new' do
    # do this for admin,atl,owner and vendor -- need negative test for non access
    login_users_and_test([]) do
      get :new, vendor_id: Vendor.first.id, product_id: Product.new
      assert_response :success
      assert_not_nil assigns(:product)
    end
  end

  test 'should get edit' do
    # do this for admin, atl and user:owner -- need negative test for users that
    #do not have access
    login_users_and_test([]) do
      get :edit, id: Product.first.id
      assert_response :success
      assert_not_nil assigns(:product)
      assert_not_nil assigns(:selected_measure_ids)
    end
  end

  test 'should destroy' do
    # do this for admin, atl and user:owner -- need negative test for users that
    #do not have access
    login_users_and_test([]) do
      get :destroy, id: Product.first.id
      assert_response :redirect
    end
  end

  test 'should get show' do
    # do this for all users - need negative test for users that do not have access
    login_users_and_test([]) do
      get :show, id: Product.first.id, vendor_id: Product.first.vendor.id
      assert_response :success
      assert_not_nil assigns(:product)
    end
  end

  test 'should create' do

    # do this for admin,atl,user:owner -- need negative test for non access
    login_users_and_test([]) do
      post :create, vendor_id: Vendor.first, product: { name: 'test_product', c1_test: true, measure_ids: [Measure.first.id] }
      assert_response :redirect
      assert_not_nil assigns(:product)
    end

  end

  test 'should be able to update measures' do
    # do this for admin,atl,user:owner -- need negative test for non access
    login_users_and_test([]) do
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

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to index for unauthorized users ' do

  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to show for unauthorized users ' do

  end

  test 'should generate a PDF report' do
    get :download_pdf, vendor_id: Product.first.vendor, id: Product.first
    assert_response :success
    assert_equal 'application/pdf', response.headers['Content-Type']
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to create for unauthorized users ' do

  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to new for unauthorized users ' do

  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to delete for unauthorized users ' do

  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to update unauthorized users ' do

  end


end
