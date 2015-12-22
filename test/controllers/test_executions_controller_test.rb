require 'test_helper'
class TestExecutionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'tasks', 'test_executions', 'users')
    sign_in User.first
  end

  test 'should get show' do
    mt = Product.first.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    task = mt.tasks.build({}, C1Task)
    te = task.test_executions.build
    mt.save!
    task.save!
    te.save!

    get :show, id: te.id, task_id: task.id
    assert_response :success
    assert_not_nil assigns(:test_execution)
  end

  test 'should be able to delete test execution' do
    id = TestExecution.first.id
    delete :destroy, id: TestExecution.first.id
    assert_response 204
    assert_equal nil, TestExecution.where(_id: id).first, 'SHould have deleted test execution'
  end

  test 'should post create' do
    C1Task.any_instance.stubs(:validators).returns([])
    C1Task.any_instance.stubs(:records).returns([])

    task = Task.first
    task.product_test = ProductTest.first
    task.product_test.product = Product.first
    orig_count = task.test_executions.count

    zipfile = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good.zip'))
    upload = Rack::Test::UploadedFile.new(zipfile, 'application/zip')

    post :create, task_id: task.id, results: upload

    assert_response 302
    assert_equal task.test_executions.count, orig_count + 1, 'Should have added 1 new TestExecution'
  end

  test 'invalid upload type for c1 task should not create new test execution' do
    task = C1Task.first
    old_count = task.test_executions.count
    file = File.new(File.join(Rails.root, 'app/assets/images/checkmark.svg'))
    upload = Rack::Test::UploadedFile.new(file, 'image/svg')

    post :create, task_id: task.id, results: upload

    assert_equal old_count, task.test_executions.count
  end

  test 'invalid upload type for c2 task should not create new test execution' do
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
