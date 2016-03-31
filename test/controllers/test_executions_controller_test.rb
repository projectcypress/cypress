require 'test_helper'
require 'api_test'

class TestExecutionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include ActiveJob::TestHelper
  include ApiTest

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'tasks', 'test_executions', 'users', 'roles',
                        'bundles', 'measures', 'health_data_standards_svs_value_sets', 'artifacts',
                        'records', 'patient_populations')
    @vendor = Vendor.find(EHR1)
    @product = @vendor.products.find('4f57a88a1d41c851eb000004')
    @test = @product.product_tests.find('4f58f8de1d41c851eb000478')
    @task = @test.tasks.find('4f57a88a1d41c851eb000010')
  end

  def setup_c4
    product = @vendor.products.build(name: "Product #{rand}", c1_test: true, c4_test: true, measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'])
    product.product_tests.build({ name: 'my filtering test', measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'],
                                  bundle_id: '4fdb62e01d41c820f6000001' }, FilteringTest)
    product.save!
    @task_cat1 = product.product_tests.first.tasks.where(_type: 'Cat1FilterTask').first
    @task_cat3 = product.product_tests.first.tasks.where(_type: 'Cat3FilterTask').first
  end

  test 'should get show' do
    mt = @product.product_tests.build({ name: 'mtest', measure_ids: ['0001'] }, MeasureTest)
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
    mt = @product.product_tests.build({ name: 'mtest', measure_ids: ['0001'] }, MeasureTest)
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
      @task.test_executions.destroy
      te = @task.test_executions.create
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
      te = @task.test_executions.create
      delete :destroy, id: te.id
      assert_response 401
    end
  end

  test 'should not be able to delete test execution if incorrect test_execution id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      @task.test_executions.destroy
      te = @task.test_executions.create
      delete :destroy, task_id: @task.id, id: 'bad_id'
      assert_response 404, 'response should be Not Found if no test_execution'
      assert_equal '', response.body
    end
  end

  test 'should be able to delete test execution if incorrect task id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      te = @task.test_executions.create
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

    orig_count = @task.test_executions.count

    zipfile = File.new(File.join(Rails.root, 'test/fixtures/product_tests/cms111v3_catiii.xml'))
    upload = Rack::Test::UploadedFile.new(zipfile, 'text/xml')
    i = 0
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      i += 1
      post :create, task_id: @task.id, results: upload
      assert_response 302
      @task.reload
      assert_equal @task.test_executions.count, orig_count + i, 'Should have added #{i} new TestExecution'
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to create unauthorized users ' do
    C1Task.any_instance.stubs(:validators).returns([])
    C1Task.any_instance.stubs(:records).returns([])

    zipfile = File.new(File.join(Rails.root, 'test/fixtures/product_tests/cms111v3_catiii.xml'))
    upload = Rack::Test::UploadedFile.new(zipfile, 'text/xml')
    for_each_logged_in_user([OTHER_VENDOR]) do
      post :create, task_id: @task.id, results: upload
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

  # # # # # # # # # # # # # # # #
  #   C 4   F I L T E R I N G   #
  # # # # # # # # # # # # # # # #

  # JSON

  test 'should create test_execution with json request with c4 cat 1 task' do
    setup_c4
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :format => :json, :task_id => @task_cat1.id, :results => zip_upload
      assert_response 201, 'response should be Created on test_execution creation'
      assert_equal('', response.body, 'response body should be empty on test_execution creation')
      assert_equal(task_test_execution_path(@task_cat1, @task_cat1.most_recent_execution), response.location,
                   'response location should be test_execution show')
    end
  end

  test 'should create test_execution with json request with c4 cat 3 task' do
    setup_c4
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :format => :json, :task_id => @task_cat3.id, :results => xml_upload
      assert_response 201, 'response should be Created on test_execution creation'
      assert_equal('', response.body, 'response body should be empty on test_execution creation')
      assert_equal(task_test_execution_path(@task_cat3, @task_cat3.most_recent_execution), response.location,
                   'response location should be test_execution show')
    end
  end

  # XML

  test 'should create test_execution with xml request with c4 cat 1 task' do
    setup_c4
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :format => :xml, :task_id => @task_cat1.id, :results => zip_upload
      assert_response 201, 'response should be Created on test_execution creation'
      assert_equal('', response.body, 'response body should be empty on test_execution creation')
      assert_equal(task_test_execution_path(@task_cat1, @task_cat1.most_recent_execution), response.location,
                   'response location should be test_execution show')
    end
  end

  test 'should create test_execution with xml request with c4 cat 3 task' do
    setup_c4
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :format => :xml, :task_id => @task_cat3.id, :results => xml_upload
      assert_response 201, 'response should be Created on test_execution creation'
      assert_equal('', response.body, 'response body should be empty on test_execution creation')
      assert_equal(task_test_execution_path(@task_cat3, @task_cat3.most_recent_execution), response.location,
                   'response location should be test_execution show')
    end
  end

  # Unsuccessful Requests

  test 'should not create test_execution with json request with cat 1 c4 task if incorrect upload type' do
    setup_c4
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :format => :json, :task_id => @task_cat1.id, :results => xml_upload
      assert_response 422, 'response should be Unprocessable Entity if invalid upload type'
      assert_not_nil JSON.parse(response.body)['errors']
    end
  end

  test 'should not create test_execution with json request with cat 3 c4 task if incorrect upload type' do
    setup_c4
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :format => :json, :task_id => @task_cat3.id, :results => zip_upload
      assert_response 422, 'response should be Unprocessable Entity if invalid upload type'
      assert_not_nil JSON.parse(response.body)['errors']
    end
  end

  # # # # # # #
  #   A P I   #
  # # # # # # #

  # JSON

  test 'should get index with json request' do
    make_first_task_type('C1Task')
    @task.test_executions.create
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :format => :json, :task_id => @task.id
      response_body = JSON.parse(response.body)
      assert_response 200, 'response should be OK on test_execution index'
      assert response_body.count > 0
      response_body.each do |response_object|
        assert response_object
      end
    end
  end

  test 'should get show with json request' do
    make_first_task_type('C1Task')
    execution = @task.test_executions.build({})
    execution.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :json, :task_id => @task.id, :id => execution.id
      response_body = JSON.parse(response.body)
      assert_response 200, 'response should be OK on test_execution show'
      assert_has_test_execution_attributes response_body
    end
  end

  test 'should get show with json request with no task_id' do
    make_first_task_type('C1Task')
    execution = @task.test_executions.build({})
    execution.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :json, :id => execution.id
      response_body = JSON.parse(response.body)
      assert_response 200, 'response should be OK if no task_id'
      assert_has_test_execution_attributes response_body
    end
  end

  test 'should create test_execution with json request' do
    make_first_task_type('C1Task')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :format => :json, :task_id => @task.id, :results => zip_upload
      assert_response 201, 'response should be Created on test_execution creation'
      assert_equal('', response.body, 'response body should be empty on test_execution creation')
      assert_equal(task_test_execution_path(@task, @task.most_recent_execution), response.location,
                   'response location should be test_execution show')
    end
  end

  test 'should see execution_errors when test_execution is ready after json request' do
    make_first_task_type('C1Task')
    @task.product_test = @product.product_tests.build({ name: 'mtest', measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'] }, MeasureTest)
    @task.product_test.save!
    @task.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      perform_enqueued_jobs do
        post :create, :format => :json, :task_id => @task.id, :results => zip_upload
        get :show, :format => :json, :task_id => @task.id, :id => @task.most_recent_execution.id
        assert_response 200, 'response should be OK on test_execution show'
        assert_not_equal 'pending', JSON.parse(response.body)['state']
      end
    end
  end

  # XML

  test 'should get index with xml request' do
    @task.test_executions.create
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :format => :xml, :task_id => @task.id
      response_body = Hash.from_trusted_xml(response.body)
      assert_response 200, 'response should be OK on test_execution index'
      assert response_body['test_executions'].count > 0
    end
  end

  test 'should get show with xml request' do
    execution = @task.test_executions.build({})
    execution.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :xml, :task_id => @task.id, :id => execution.id
      response_body = Hash.from_trusted_xml(response.body)
      assert_response 200, 'response should be OK on test_execution show'
      assert_has_test_execution_attributes response_body['test_execution']
    end
  end

  test 'should get show with xml request with no task_id' do
    execution = @task.test_executions.build({})
    execution.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :xml, :id => execution.id
      response_body = Hash.from_trusted_xml(response.body)
      assert_response 200, 'response should be OK if no task_id'
      assert_has_test_execution_attributes response_body['test_execution']
    end
  end

  test 'should create test_execution with xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :format => :xml, :task_id => @task.id, :results => xml_upload
      assert_response 201, 'response should be Created on test_execution creation'
      assert_equal('', response.body, 'response body should be empty on test_execution creation')
      assert_equal(task_test_execution_path(@task, @task.most_recent_execution), response.location,
                   'response location should be test_execution show')
    end
  end

  test 'should see execution_errors when test_execution is ready after xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      perform_enqueued_jobs do
        @task.product_test = @product.product_tests.build({ name: 'mtest2', measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'] }, MeasureTest)
        @task.product_test.save!
        @task.save!
        post :create, :format => :xml, :task_id => @task.id, :results => xml_upload
        get :show, :format => :xml, :task_id => @task.id, :id => @task.most_recent_execution.id
        assert_response 200, 'response should be OK on test_execution show'
        assert_not_equal 'pending', Hash.from_trusted_xml(response.body)['test_execution']['state']
      end
    end
  end

  # Unsuccessful Requests

  test 'should not get show with json request with bad test_execution id' do
    make_first_task_type('C1Task')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :format => :json, :task_id => @task.id, :id => 'bad_id'
      assert_response 404, 'response should be Bad Request if no test_execution'
      assert_equal '', response.body
    end
  end

  test 'should not create test_execution with json request with no upload' do
    make_first_task_type('C1Task')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :format => :json, :task_id => @task.id
      assert_response 422, 'response should be Unprocessable Entity if no results given'
      assert_not_nil JSON.parse(response.body)['errors']
    end
  end

  test 'should not create test_execution with json request with nil upload' do
    make_first_task_type('C1Task')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :format => :json, :task_id => @task.id, :results => nil
      assert_response 422, 'response should be Unprocessable Entity if nil results given'
      assert_not_nil JSON.parse(response.body)['errors']
    end
  end

  test 'should not create test_execution with json request if incorrect upload type' do
    make_first_task_type('C1Task')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :format => :json, :task_id => @task.id, :results => xml_upload
      assert_response 422, 'response should be Unprocessable Entity if no test_execution'
      assert_not_nil JSON.parse(response.body)['errors']
    end
  end

  # # # # # # # # # # #
  #   H E L P E R S   #
  # # # # # # # # # # #

  def assert_has_test_execution_attributes(hash)
    assert_has_attributes(hash, accepted_execution_show_attributes)
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
    %w(state created_at)
  end

  def make_first_task_type(type)
    @task._type = type
    @task.save!
  end
end
