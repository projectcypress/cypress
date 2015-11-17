require 'test_helper'
class TestExecutionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'tasks', 'test_executions', 'users')
    sign_in User.first
  end
  teardown do
    drop_database
  end

  test 'should get index' do
    get :index, task_id: Task.first.id
    assert_response :success
    assert_not_nil assigns(:test_executions)
  end

  test 'should get show' do
    get :show, id: TestExecution.first.id
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
end
