require 'test_helper'
class ProductTestsControllerTest < ActionController::TestCase
  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'users', 'roles')
    @vendor = Vendor.find(EHR1)
    @first_product = @vendor.products.first
    @first_test = @first_product.product_tests.first
  end

  test 'should get index' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, product_id: @first_product.id
      assert_response :success, "#{@user.email} should have access "
      assert_not_nil assigns(:product_tests)
      assert_not_nil assigns(:product)
    end
  end

  test 'should restrict acces to product test index' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :index, product_id: @first_product.id
      assert_response 401
    end
  end

  test 'should get show' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      my_product = @first_product.product_tests.first
      get :show, id: my_product.id, product_id: @first_product.id
      assert_response :success, "#{@user.email} should have access "
      assert_not_nil assigns(:product_test)
    end
  end

  test 'should restrict acces to product test show' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      my_product = @first_test
      get :show, id: my_product.id, product_id: @first_product.id
      assert_response 401
    end
  end

  test 'should get show measure test' do
    mt = Product.first.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    mt.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, id: mt.id, product_id: mt.product.id
      assert_response :success, "#{@user.email} should have access "
      assert_not_nil assigns(:product_test)
    end
  end

  test 'should restrict acces to product measure  test show' do
    mt = Product.first.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    mt.save!
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :show, id: mt.id, product_id: mt.product.id
      assert_response 401
    end
  end

  test 'should get edit' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :edit, id: @first_test.id
      assert_response :success, "#{@user.email} should have access "
      assert_not_nil assigns(:product_test)
    end
  end

  test 'should restrict acces to product test edit' do
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      get :edit, id: @first_test.id
      assert_response 401
      assert_not_nil assigns(:product_test)
    end
  end

  test 'should be able to download zip file of patients in qrda format' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :download, :id => @first_test.id, :format => :qrda
      assert_response :success, "#{@user.email} should have access "
      assert_not_nil assigns(:product_test)
    end
  end

  test 'should restrict acces to product download qrda ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :download, :id => @first_test.id, :format => :qrda
      assert_response 401
    end
  end

  test 'should be able to download zip file of patients in html format' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :download, :id => @first_test.id, :format => :html
      assert_response :success, "#{@user.email} should have access "
      assert_not_nil assigns(:product_test)
    end
  end

  test 'should restrict acces to product download html ' do
    # do this for all users
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :download, :id => @first_test.id, :format => :html
      assert_response 401
    end
  end
  # need negative tests for user that does not have owner or vendor access
end
