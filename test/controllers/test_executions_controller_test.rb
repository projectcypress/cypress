require 'test_helper'
class TestExecutionsControllerTest < ActionController::TestCase
  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'tasks', 'test_executions', 'users', 'roles')
    @vendor = Vendor.find(EHR1)
    @first_product = @vendor.products.first
    @first_test = @first_product.product_tests.first
    @first_task = @first_test.tasks.first
    @first_execution = @first_task.test_executions.first
  end

  test 'should get show' do
    mt = @first_product.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    task = mt.tasks.build({}, C1Task)
    te = task.test_executions.build
    mt.save!
    task.save!
    te.save!
    # do this for admin,atl,user:owner and vendor -- need negative tests for non
    # access users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, id: te.id, task_id: task.id
      assert_response :success
      assert_not_nil assigns(:test_execution)
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to show unauthorized users ' do
    mt = @first_product.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    task = mt.tasks.build({}, C1Task)
    te = task.test_executions.build
    mt.save!
    task.save!
    te.save!
    # do this for admin,atl,user:owner and vendor -- need negative tests for non
    # access users
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :show, id: te.id, task_id: task.id
      assert_response 404
    end
  end

  test 'should be able to delete test execution' do
    # do this for admin,atl,user:owner -- need negative tests for non
    # access users
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      te = @first_task.test_executions.create
      id = te.id
      delete :destroy, id: id
      assert_response 204
      assert_equal nil, TestExecution.where(_id: id).first, 'SHould have deleted test execution'
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to delete unauthorized users ' do
    # do this for admin,atl,user:owner -- need negative tests for non
    # access users
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      te = @first_task.test_executions.create
      id = te.id
      delete :destroy, id: id
      assert_response 404
    end
  end

  test 'should post create' do
    # do this for admin,atl,user:owner -- need negative tests for non
    # access users
    C1Task.any_instance.stubs(:validators).returns([])
    C1Task.any_instance.stubs(:records).returns([])

    orig_count = @first_task.test_executions.count

    zipfile = File.new(File.join(Rails.root, 'test/fixtures/product_tests/cms111v3_catiii.xml'))
    upload = Rack::Test::UploadedFile.new(zipfile, 'text/xml')
    i = 0
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      i += 1
      post :create, task_id: @first_task.id, results: upload
      assert_response 302
      @first_task.reload
      assert_equal @first_task.test_executions.count, orig_count + i, 'Should have added #{i} new TestExecution'
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to create unauthorized users ' do
    C1Task.any_instance.stubs(:validators).returns([])
    C1Task.any_instance.stubs(:records).returns([])

    zipfile = File.new(File.join(Rails.root, 'test/fixtures/product_tests/cms111v3_catiii.xml'))
    upload = Rack::Test::UploadedFile.new(zipfile, 'text/xml')
    for_each_logged_in_user([OTHER_VENDOR]) do
      post :create, task_id: @first_task.id, results: upload
      assert_response 404
    end
  end

  test 'invalid upload type for c1 task should not create new test execution' do
    # only need to do this for admin -- its checking error in file and the
    # access is already tested
    sign_in User.find(ADMIN)
    task = C1Task.first
    old_count = task.test_executions.count
    file = File.new(File.join(Rails.root, 'app/assets/images/checkmark.svg'))
    upload = Rack::Test::UploadedFile.new(file, 'image/svg')
    post :create, task_id: task.id, results: upload

    assert_equal old_count, task.test_executions.count
  end

  test 'invalid upload type for c2 task should not create new test execution' do
    # only need to do this for admin -- its checking error in file and the
    # access is already tested
    sign_in User.find(ADMIN)
    task = C1Task.first
    task._type = 'C2Task'
    task.save!
    old_count = task.test_executions.count
    file = File.new(File.join(Rails.root, 'app/assets/images/checkmark.svg'))
    upload = Rack::Test::UploadedFile.new(file, 'image/svg')

    post :create, task_id: task.id, results: upload

    assert_equal old_count, task.test_executions.count
  end
end
