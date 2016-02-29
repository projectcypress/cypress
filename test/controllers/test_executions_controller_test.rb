require 'test_helper'
class TestExecutionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include ActiveJob::TestHelper

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'tasks', 'test_executions', 'users', 'roles',
                        'bundles', 'measures', 'health_data_standards_svs_value_sets', 'artifacts',
                        'records', 'patient_populations')
    @vendor = Vendor.find(EHR1)
    @first_product = @vendor.products.first
    @first_test = @first_product.product_tests.first
    @first_task = @first_test.tasks.first
    @first_execution = @first_task.test_executions.first
  end

  test 'should get show' do
    mt = @first_product.product_tests.build({ name: 'mtest', measure_ids: ['0001'] }, MeasureTest)
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
    mt = @first_product.product_tests.build({ name: 'mtest', measure_ids: ['0001'] }, MeasureTest)
    task = mt.tasks.build({}, C1Task)
    te = task.test_executions.build
    mt.save!
    task.save!
    te.save!
    # do this for admin,atl,user:owner and vendor -- need negative tests for non
    # access users
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :show, id: te.id, task_id: task.id
      assert_response 401
    end
  end

  # delete

  test 'should be able to delete test execution' do
    # do this for admin,atl,user:owner -- need negative tests for non
    # access users
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      @first_task.test_executions.destroy
      te = @first_task.test_executions.create
      delete :destroy, id: te.id
      assert_response 204, 'response should be No Content on test_execution destroy'
      assert_equal nil, TestExecution.where(_id: te.id).first, 'Should have deleted test execution'
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to delete unauthorized users ' do
    # do this for admin,atl,user:owner -- need negative tests for non
    # access users
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      te = @first_task.test_executions.create
      delete :destroy, id: te.id
      assert_response 401
    end
  end

  test 'should not be able to delete test execution if incorrect test_execution id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      @first_task.test_executions.destroy
      te = @first_task.test_executions.create
      delete :destroy, task_id: @first_task.id, id: 'bad_id'
      assert_response 404, 'response should be Not Found if no test_execution'
      assert_equal '', response.body
    end
  end

  test 'should be able to delete test execution if incorrect task id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      te = @first_task.test_executions.create
      delete :destroy, task_id: 'bad_id', id: te.id
      assert_response 204, 'response should be No Content on test_execution destroy'
      assert_equal nil, TestExecution.where(_id: te.id).first, 'Should have deleted test execution'
    end
  end

  # create

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
      assert_response 401
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

  # # # # # # #
  #   A P I   #
  # # # # # # #

  # JSON

  test 'should get index with json request' do
    task = TestExecution.first.task
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :index, :format => :json, :task_id => task.id
      response_body = JSON.parse(response.body)
      assert_response 200, 'response should be OK on test_execution index'
      assert response_body.count > 0
      response_body.each do |response_object|
        assert response_object['test_execution']
      end
    end
  end

  test 'should get test_execution with json request' do
    task = C1Task.first
    execution = task.test_executions.build({})
    execution.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :show, :format => :json, :task_id => task.id, :id => execution.id
      response_body = JSON.parse(response.body)
      assert_response 200, 'response should be OK on test_execution show'
      assert_not_nil response_body['test_execution'], 'response body should include test_execution'
      assert_equal 'pending', response_body['test_execution']['state'], 'test_execution should have state of pending'
    end
  end

  test 'should get response bad request if no test_execution' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :show, :format => :json, :task_id => C1Task.first.id, :id => 'bad_id'
      assert_response 404, 'response should be Bad Request if no test_execution'
      assert_equal '', response.body
    end
  end

  test 'should create test_execution with json request' do
    task = C1Task.first
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, :format => :json, :task_id => task.id, :results => zip_upload
      assert_response 201, 'response should be Created on test_execution creation'
      assert_equal('', response.body, 'response body should be empty on test_execution creation')
      assert_equal(task_test_execution_path(task, task.most_recent_execution), response.location, 'response location should be test_execution show')
    end
  end

  test 'should get response bad request if incorrect upload type for json request' do
    task = C1Task.first
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, :format => :json, :task_id => task.id, :results => xml_upload
      assert_response 422, 'response should be Unprocessable Entity if no test_execution'
      assert_equal '', response.body
    end
  end

  test 'should see execution_errors when test_execution is ready after json request' do
    task = C1Task.first
    task.product_test = Product.first.product_tests.build({ name: 'mtest', measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    task.product_test.save!
    task.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      perform_enqueued_jobs do
        post :create, :format => :json, :task_id => task.id, :results => zip_upload
        get :show, :format => :json, :task_id => task.id, :id => task.most_recent_execution.id
        assert_response 200, 'response should be OK on test_execution show'
        assert_not_equal 'pending', JSON.parse(response.body)['test_execution']['state']
        assert_valid_create_attributes JSON.parse(response.body)['test_execution']
      end
    end
  end

  # XML

  test 'should get test_execution with xml request' do
    task = C1Task.first
    execution = task.test_executions.build({})
    execution.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :show, :format => :xml, :task_id => task.id, :id => execution.id
      response_body = Hash.from_trusted_xml(response.body)
      assert_response 200, 'response should be OK on test_execution show'
      assert_not_nil response_body['test_execution'], 'response body should include test_execution'
      assert_equal :pending, response_body['test_execution']['state'], 'test_execution should have state of pending'
    end
  end

  test 'should get index with xml request' do
    task = TestExecution.first.task
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :index, :format => :xml, :task_id => task.id
      response_body = Hash.from_trusted_xml(response.body)
      assert_response 200, 'response should be OK on test_execution index'
      assert response_body['test_executions'].count > 0
    end
  end

  test 'should get test_execution with xml request with no task_id' do
    task = C1Task.first
    execution = task.test_executions.build({})
    execution.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :show, :format => :xml, :id => execution.id
      response_body = Hash.from_trusted_xml(response.body)
      assert_response 404, 'response should be Bad Request if no test_execution'
      assert_equal '', response.body
    end
  end

  test 'should get response bad request after xml request if no test_execution' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      get :show, :format => :xml, :task_id => C1Task.first.id, :id => 'bad_id'
      assert_response 404, 'response should be Bad Request if no test_execution'
      assert_equal '', response.body
    end
  end

  test 'should create test_execution with xml request' do
    task = C2Task.first
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, :format => :xml, :task_id => task.id, :results => xml_upload
      assert_response 201, 'response should be Created on test_execution creation'
      assert_equal('', response.body, 'response body should be empty on test_execution creation')
      assert_equal(task_test_execution_path(task, task.most_recent_execution), response.location, 'response location should be test_execution show')
    end
  end

  test 'should get response bad request if incorrect upload type for xml request' do
    task = C2Task.first
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      post :create, :format => :xml, :task_id => task.id, :results => zip_upload
      assert_response 422, 'response should be Bad Request if no test_execution'
      assert_equal '', response.body
    end
  end

  test 'should see execution_errors when test_execution is ready after xml request' do
    task = C2Task.first
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      perform_enqueued_jobs do
        task.product_test = Product.first.product_tests.build({ name: 'mtest2', measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
        task.product_test.save!
        task.save!
        post :create, :format => :xml, :task_id => task.id, :results => xml_upload
        get :show, :format => :xml, :task_id => task.id, :id => task.most_recent_execution.id
        assert_response 200, 'response should be OK on test_execution show'
        assert_not_equal 'pending', Hash.from_trusted_xml(response.body)['test_execution']['state']
        assert_valid_create_attributes Hash.from_trusted_xml(response.body)['test_execution']
      end
    end
  end

  # # # # # # # # # # #
  #   H E L P E R S   #
  # # # # # # # # # # #

  def assert_valid_create_attributes(execution_hash)
    assert_equal 0, (execution_hash.keys - accepted_execution_show_attributes).count
  end

  def zip_upload
    zipfile = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good.zip'))
    Rack::Test::UploadedFile.new(zipfile, 'application/zip')
  end

  def xml_upload
    xmlfile = File.new(File.join(Rails.root, 'test/fixtures/product_tests/cms111v3_catiii.xml'))
    Rack::Test::UploadedFile.new(xmlfile, 'application/xml')
  end

  def accepted_execution_show_attributes
    %w(state execution_errors created_at updated_at sibling_execution_id)
  end
end
