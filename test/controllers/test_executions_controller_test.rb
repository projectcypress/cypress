require 'test_helper'
require 'api_test'

class TestExecutionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include ActiveJob::TestHelper
  include ApiTest
  include TestExecutionsHelper

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'tasks', 'test_executions', 'users', 'roles',
                        'bundles', 'measures', 'health_data_standards_svs_value_sets', 'artifacts',
                        'records', 'patient_populations', 'providers')
    load_library_functions
    @vendor = Vendor.find(EHR1)
    @first_product = @vendor.products.where(name: 'Vendor 1 Product 1').find('4f57a88a1d41c851eb000004')
    @first_product.bundle = Bundle.default
    @first_product.save
    @first_test = @first_product.product_tests.where(name: 'vendor1 product1 test1').find('4f58f8de1d41c851eb000478')
    @first_task = @first_test.tasks.find('4f57a88a1d41c851eb000010')
    @first_execution = @first_task.test_executions.first
  end

  def setup_c4
    product = @vendor.products.build(name: "Product #{rand}", c1_test: true, c4_test: true, measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'], bundle_id: '4fdb62e01d41c820f6000001')
    product.product_tests.build({ name: 'my filtering test', measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'],
                                  bundle_id: '4fdb62e01d41c820f6000001' }, FilteringTest)
    product.save!
    @task_cat1 = product.product_tests.find_by(name: 'my filtering test').tasks.where(_type: 'Cat1FilterTask').first
    @task_cat3 = product.product_tests.find_by(name: 'my filtering test').tasks.where(_type: 'Cat3FilterTask').first
  end

  test 'should get show' do
    # change product test to measure test, create test execution for measure test
    test = ProductTest.find('51703a883054cf84390000d3')
    test._type = MeasureTest
    test.save!
    test = ProductTest.find(test.id) # reload test variable to it is a measure test instead of product test
    product = test.product
    product.vendor = @vendor
    product.c1_test = true
    product.measure_ids = test.measure_ids
    product.save!
    task = test.tasks.build({}, C1Task)
    task.save!
    te = task.test_executions.build
    te.save!

    # add provider performance to each record associated with the measure test
    provider = Provider.find('53b2c4414d4d32139c730000')
    test.provider = provider
    test.save!
    test.records.each do |record|
      pp = record.provider_performances.build(provider: provider)
      pp.save!
    end

    # do this for admin,atl,user:owner and vendor -- need negative tests for non
    # access users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, params: { id: te.id, task_id: task.id }
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
      get :show, params: { id: te.id, task_id: task.id }
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
      delete :destroy, params: { id: te.id }
      assert_response 204, 'response should be No Content on test_execution destroy'
      assert_nil TestExecution.where(_id: te.id).first, 'Should have deleted test execution'
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to delete unauthorized users ' do
    # do this for admin,atl,user:owner -- need negative tests for non
    # access users
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      te = @first_task.test_executions.create
      delete :destroy, params: { id: te.id }
      assert_response 401
    end
  end

  test 'should not be able to delete test execution if incorrect test_execution id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      @first_task.test_executions.destroy
      @first_task.test_executions.create
      delete :destroy, params: { task_id: @first_task.id, id: 'bad_id' }
      assert_response 404, 'response should be Not Found if no test_execution'
      assert_equal 'Not Found', response.message
    end
  end

  test 'should be able to delete test execution if incorrect task id' do
    for_each_logged_in_user([ADMIN, ATL, OWNER]) do
      te = @first_task.test_executions.create
      delete :destroy, params: { task_id: 'bad_id', id: te.id }
      assert_response 204, 'response should be No Content on test_execution destroy'
      assert_nil TestExecution.where(_id: te.id).first, 'Should have deleted test execution'
    end
  end

  # create

  test 'should post create' do
    # do this for admin,atl,user:owner -- need negative tests for non
    # access users
    C1Task.any_instance.stubs(:validators).returns([])
    C1Task.any_instance.stubs(:records).returns([])

    orig_count = @first_task.test_executions.count

    zipfile = File.new(Rails.root.join('test/fixtures/product_tests/cms111v3_catiii.xml'))
    upload = Rack::Test::UploadedFile.new(zipfile, 'text/xml')
    i = 0
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      i += 1
      post :create, params: { task_id: @first_task.id, results: upload }
      assert_response 302
      @first_task.reload
      assert_equal @first_task.test_executions.count, orig_count + i, 'Should have added #{i} new TestExecution'
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to create unauthorized users ' do
    C1Task.any_instance.stubs(:validators).returns([])
    C1Task.any_instance.stubs(:records).returns([])

    zipfile = File.new(Rails.root.join('test/fixtures/product_tests/cms111v3_catiii.xml'))
    upload = Rack::Test::UploadedFile.new(zipfile, 'text/xml')
    for_each_logged_in_user([OTHER_VENDOR]) do
      post :create, params: { task_id: @first_task.id, results: upload }
      assert_response 401
    end
  end

  test 'invalid upload type for c1 task should not create new test execution' do
    # only need to do this for admin -- its checking error in file and the
    # access is already tested
    sign_in User.find(ADMIN)
    task = C1Task.find('4f57a88a1d41c851eb000004')
    old_count = task.test_executions.count
    file = File.new(Rails.root.join('app/assets/images/icon.svg'))
    upload = Rack::Test::UploadedFile.new(file, 'image/svg')
    post :create, params: { task_id: task.id, results: upload }

    assert_equal old_count, task.test_executions.count
  end

  test 'invalid upload type for c2 task should not create new test execution' do
    # only need to do this for admin -- its checking error in file and the
    # access is already tested
    sign_in User.find(ADMIN)
    task = C1Task.find('4f57a88a1d41c851eb000004')
    task._type = 'C2Task'
    task.save!
    old_count = task.test_executions.count
    file = File.new(Rails.root.join('app/assets/images/icon.svg'))
    upload = Rack::Test::UploadedFile.new(file, 'image/svg')

    post :create, params: { task_id: task.id, results: upload }

    assert_equal old_count, task.test_executions.count
  end

  # file_result

  test 'should be able to get file_result if valid execution id and file name' do
    %w[C1Task C2Task Cat1FilterTask Cat3FilterTask C1ChecklistTask].each do |task_type|
      execution, file_name = create_execution_with_task_type(task_type)
      for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
        get :file_result, params: { id: execution.id, file_name: route_file_name(file_name) }
        assert_response 200, "should be able to find file with file name \"#{file_name}\""
      end
    end
  end

  test 'other vendors should not be able to get file_result' do
    %w[C1Task C2Task Cat1FilterTask Cat3FilterTask C1ChecklistTask].each do |task_type|
      execution, file_name = create_execution_with_task_type(task_type)
      for_each_logged_in_user([OTHER_VENDOR]) do
        get :file_result, params: { id: execution.id, file_name: route_file_name(file_name) }
        assert_response 401, "other vendor should not be authorized to view file: \"#{file_name}\""
      end
    end
  end

  test 'should not be able to get file_result if invalid execution id' do
    %w[C1Task C2Task Cat1FilterTask Cat3FilterTask C1ChecklistTask].each do |task_type|
      _execution, file_name = create_execution_with_task_type(task_type)
      for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
        bad_execution_id = "bad id #{rand}"
        get :file_result, params: { id: bad_execution_id, file_name: route_file_name(file_name) }
        assert_response 404, "should not be able to find file with bad execution id \"#{bad_execution_id}\""
        assert_equal 'Not Found', response.message
      end
    end
  end

  test 'should not be able to get file_result if invalid file_name' do
    %w[C1Task C2Task Cat1FilterTask Cat3FilterTask C1ChecklistTask].each do |task_type|
      execution, _file_name = create_execution_with_task_type(task_type)
      for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
        bad_file_name = "bad file name #{rand}"
        get :file_result, params: { id: execution.id, file_name: route_file_name(bad_file_name) }
        assert_response 404, "should not be able to find file with bad file name \"#{bad_file_name}\""
        assert_equal 'Not Found', response.message
      end
    end
  end

  def create_execution_with_task_type(task_type)
    c1, c2, c4 = c1_c2_c4_from_task_type(task_type)
    measure_ids = ['40280381-4BE2-53B3-014C-0F589C1A1C39']
    product = @vendor.products.create!(name: "my product #{rand}", bundle_id: '4fdb62e01d41c820f6000001', measure_ids: measure_ids,
                                       c1_test: c1, c2_test: c2, c4_test: c4)
    test = product.product_tests.create!({ name: "my measure test #{rand}", measure_ids: measure_ids }, MeasureTest)
    task = create_task_from_task_type(test, task_type)
    execution = task.test_executions.create!
    case task_type
    when 'C1Task', 'Cat1FilterTask', 'C1ChecklistTask'
      file_name = 'c1_checklist_incorrect_codes.zip'
    when 'C2Task', 'Cat3FilterTask'
      file_name = 'cms111v3_catiii.xml'
    end
    file = File.new(Rails.root.join("test/fixtures/product_tests/#{file_name}"))
    Artifact.create!(test_execution: execution, file: file)
    unzipped_file_name = execution.artifact.file_names.first
    execution.execution_errors.create!(:message => "my error message #{rand}", :msg_type => :my_msg_type, :file_name => unzipped_file_name)
    [execution, unzipped_file_name]
  end

  # returns [c1, c2, c4]
  def c1_c2_c4_from_task_type(task_type)
    case task_type
    when 'C1Task', 'C1ChecklistTask'
      [true, false, false]
    when 'C2Task'
      [false, true, false]
    when 'Cat1FilterTask', 'Cat3FilterTask'
      [true, false, true]
    end
  end

  def create_task_from_task_type(test, task_type)
    case task_type
    when 'C1Task'
      test.tasks.create!({}, C1Task)
    when 'C2Task'
      test.tasks.create!({}, C2Task)
    when 'Cat1FilterTask'
      test.tasks.create!({}, Cat1FilterTask)
    when 'Cat3FilterTask'
      test.tasks.create!({}, Cat3FilterTask)
    when 'C1ChecklistTask'
      test.tasks.create!({}, C1ChecklistTask)
    end
  end

  # # # # # # # # # # # # # # # #
  #   C 4   F I L T E R I N G   #
  # # # # # # # # # # # # # # # #

  # JSON

  test 'should create test_execution with json request with c4 cat 1 task' do
    setup_c4
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :params => { :format => :json, :task_id => @task_cat1.id, :results => zip_upload }
      assert_response 201, 'response should be Created on test_execution creation'
      assert_not_nil JSON.parse(response.body)
      assert_equal 'pending', JSON.parse(response.body)['state']
      assert response.location.end_with?(test_execution_path(@task_cat1.most_recent_execution)),
             'response location should be test_execution show'
    end
  end

  test 'should create test_execution with json request with c4 cat 3 task' do
    setup_c4
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :params => { :format => :json, :task_id => @task_cat3.id, :results => xml_upload }
      assert_response 201, 'response should be Created on test_execution creation'
      assert_not_nil JSON.parse(response.body)
      assert_equal 'pending', JSON.parse(response.body)['state']
      assert response.location.end_with?(test_execution_path(@task_cat3.most_recent_execution)),
             'response location should be test_execution show'
    end
  end

  # XML

  test 'should create test_execution with xml request with c4 cat 1 task' do
    setup_c4
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :params => { :format => :xml, :task_id => @task_cat1.id, :results => zip_upload }
      assert_response 201, 'response should be Created on test_execution creation'
      assert_not_nil Hash.from_trusted_xml(response.body)
      assert_equal 'pending', Hash.from_trusted_xml(response.body)['test_execution']['state']
      assert response.location.end_with?(test_execution_path(@task_cat1.most_recent_execution)),
             'response location should be test_execution show'
    end
  end

  test 'should create test_execution with xml request with c4 cat 3 task' do
    setup_c4
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :params => { :format => :xml, :task_id => @task_cat3.id, :results => xml_upload }
      assert_response 201, 'response should be Created on test_execution creation'
      assert_not_nil Hash.from_trusted_xml(response.body)
      assert_equal 'pending', Hash.from_trusted_xml(response.body)['test_execution']['state']
      assert response.location.end_with?(test_execution_path(@task_cat3.most_recent_execution)),
             'response location should be test_execution show'
    end
  end

  # Unsuccessful Requests

  test 'should not create test_execution with cat 1 c4 task if incorrect upload type' do
    setup_c4
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :params => { :format => :json, :task_id => @task_cat1.id, :results => xml_upload }
      assert_response 422, 'response should be Unprocessable Entity if invalid upload type'
      assert_has_json_errors JSON.parse(response.body), 'results' => ['invalid file upload. upload a zip for QRDA Category I or XML for QRDA Category III']
      post :create, :params => { :format => :xml, :task_id => @task_cat1.id, :results => xml_upload }
      assert_response 422, 'response should be Unprocessable Entity if invalid upload type'
      assert_has_xml_errors Hash.from_trusted_xml(response.body), 'results' => ['invalid file upload. upload a zip for QRDA Category I or XML for QRDA Category III']
    end
  end

  test 'should not create test_execution with json request with cat 3 c4 task if incorrect upload type' do
    setup_c4
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :params => { :format => :json, :task_id => @task_cat3.id, :results => zip_upload }
      assert_response 422, 'response should be Unprocessable Entity if invalid upload type'
      assert_has_json_errors JSON.parse(response.body), 'results' => ['invalid file upload. upload a zip for QRDA Category I or XML for QRDA Category III']
      post :create, :params => { :format => :xml, :task_id => @task_cat3.id, :results => zip_upload }
      assert_response 422, 'response should be Unprocessable Entity if invalid upload type'
      assert_has_xml_errors Hash.from_trusted_xml(response.body), 'results' => ['invalid file upload. upload a zip for QRDA Category I or XML for QRDA Category III']
    end
  end

  # # # # # # #
  #   A P I   #
  # # # # # # #

  # JSON

  test 'should get index with json request' do
    make_first_task_type('C1Task')
    @first_task.test_executions.create
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :params => { :format => :json, :task_id => @first_task.id }
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
    execution = @first_task.test_executions.build({})
    execution.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :json, :task_id => @first_task.id, :id => execution.id }
      response_body = JSON.parse(response.body)
      assert_response 200, 'response should be OK on test_execution show'
      assert_has_test_execution_attributes response_body
    end
  end

  test 'should get show with json request with no task_id' do
    make_first_task_type('C1Task')
    execution = @first_task.test_executions.build({})
    execution.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :json, :id => execution.id }
      response_body = JSON.parse(response.body)
      assert_response 200, 'response should be OK if no task_id'
      assert_has_test_execution_attributes response_body
    end
  end

  test 'should create test_execution with json request' do
    make_first_task_type('C1Task')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :params => { :format => :json, :task_id => @first_task.id, :results => zip_upload }
      assert_response 201, 'response should be Created on test_execution creation'
      assert_not_nil JSON.parse(response.body)
      assert_equal 'pending', JSON.parse(response.body)['state']
      assert response.location.end_with?(test_execution_path(@first_task.most_recent_execution)),
             'response location should be test_execution show'
    end
  end

  test 'should see execution_errors when test_execution is ready after json request' do
    make_first_task_type('C1Task')
    @first_task.product_test = @first_product.product_tests.build({ :name => 'mtest', :measure_ids => ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'],
                                                                    :bundle_id => '4fdb62e01d41c820f6000001' }, MeasureTest)
    @first_task.product_test.save!
    @first_task.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      perform_enqueued_jobs do
        post :create, :params => { :format => :json, :task_id => @first_task.id, :results => zip_upload }
        get :show, :params => { :format => :json, :task_id => @first_task.id, :id => @first_task.most_recent_execution.id }
        assert_response 200, 'response should be OK on test_execution show'
        assert_not_equal 'pending', JSON.parse(response.body)['state']
      end
    end
  end

  # XML

  test 'should get index with xml request' do
    @first_task.test_executions.create
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, :params => { :format => :xml, :task_id => @first_task.id }
      response_body = Hash.from_trusted_xml(response.body)
      assert_response 200, 'response should be OK on test_execution index'
      assert response_body['test_executions'].count > 0
    end
  end

  test 'should get show with xml request' do
    execution = @first_task.test_executions.build({})
    execution.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :xml, :task_id => @first_task.id, :id => execution.id }
      response_body = Hash.from_trusted_xml(response.body)
      assert_response 200, 'response should be OK on test_execution show'
      assert_has_test_execution_attributes response_body['test_execution']
    end
  end

  test 'should get show with xml request with no task_id' do
    execution = @first_task.test_executions.build({})
    execution.save!
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :xml, :id => execution.id }
      response_body = Hash.from_trusted_xml(response.body)
      assert_response 200, 'response should be OK if no task_id'
      assert_has_test_execution_attributes response_body['test_execution']
    end
  end

  test 'should create test_execution with xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :params => { :format => :xml, :task_id => @first_task.id, :results => xml_upload }
      assert_response 201, 'response should be Created on test_execution creation'
      assert_not_nil Hash.from_trusted_xml(response.body)
      assert_equal 'pending', Hash.from_trusted_xml(response.body)['test_execution']['state']
      assert response.location.end_with?(test_execution_path(@first_task.most_recent_execution)),
             'response location should be test_execution show'
    end
  end

  test 'should see execution_errors when test_execution is ready after xml request' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      perform_enqueued_jobs do
        @first_task.product_test = @first_product.product_tests.build({ :name => 'mtest2',
                                                                        :measure_ids => ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'] }, MeasureTest)
        @first_task.product_test.save!
        @first_task.save!
        post :create, :params => { :format => :xml, :task_id => @first_task.id, :results => xml_upload }
        get :show, :params => { :format => :xml, :task_id => @first_task.id, :id => @first_task.most_recent_execution.id }
        assert_response 200, 'response should be OK on test_execution show'
        assert_not_equal 'pending', Hash.from_trusted_xml(response.body)['test_execution']['state']
      end
    end
  end

  # Unsuccessful Requests

  test 'should not get show with json request with bad test_execution id' do
    make_first_task_type('C1Task')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, :params => { :format => :json, :task_id => @first_task.id, :id => 'bad_id' }
      assert_response 404, 'response should be Bad Request if no test_execution'
      assert_equal 'Not Found', response.message
    end
  end

  test 'should not create test_execution with no upload' do
    make_first_task_type('C1Task')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :params => { :format => :json, :task_id => @first_task.id }
      assert_response 422, 'response should be Unprocessable Entity if no results given'
      assert_has_json_errors JSON.parse(response.body), 'results' => ['invalid file upload. upload a zip for QRDA Category I or XML for QRDA Category III']
      post :create, :params => { :format => :xml, :task_id => @first_task.id }
      assert_response 422, 'response should be Unprocessable Entity if no results given'
      assert_has_xml_errors Hash.from_trusted_xml(response.body), 'results' => ['invalid file upload. upload a zip for QRDA Category I or XML for QRDA Category III']
    end
  end

  test 'should not create test_execution with json request with nil upload' do
    make_first_task_type('C1Task')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :params => { :format => :json, :task_id => @first_task.id, :results => nil }
      assert_response 422, 'response should be Unprocessable Entity if nil results given'
      assert_has_json_errors JSON.parse(response.body), 'results' => ['invalid file upload. upload a zip for QRDA Category I or XML for QRDA Category III']
      post :create, :params => { :format => :xml, :task_id => @first_task.id, :results => nil }
      assert_response 422, 'response should be Unprocessable Entity if no results given'
      assert_has_xml_errors Hash.from_trusted_xml(response.body), 'results' => ['invalid file upload. upload a zip for QRDA Category I or XML for QRDA Category III']
    end
  end

  test 'should not create test_execution with json request if incorrect upload type' do
    make_first_task_type('C1Task')
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      post :create, :params => { :format => :json, :task_id => @first_task.id, :results => xml_upload }
      assert_response 422, 'response should be Unprocessable Entity if no test_execution'
      assert_has_json_errors JSON.parse(response.body), 'results' => ['invalid file upload. upload a zip for QRDA Category I or XML for QRDA Category III']
      post :create, :params => { :format => :xml, :task_id => @first_task.id, :results => xml_upload }
      assert_response 422, 'response should be Unprocessable Entity if no results given'
      assert_has_xml_errors Hash.from_trusted_xml(response.body), 'results' => ['invalid file upload. upload a zip for QRDA Category I or XML for QRDA Category III']
    end
  end

  # # # # # # # # # # #
  #   H E L P E R S   #
  # # # # # # # # # # #

  def assert_has_test_execution_attributes(hash)
    assert_has_attributes(hash, accepted_execution_show_attributes)
  end

  def zip_upload
    zipfile = File.new(Rails.root.join('test/fixtures/product_tests/ep_qrda_test_good.zip'))
    Rack::Test::UploadedFile.new(zipfile, 'application/zip')
  end

  def xml_upload
    xmlfile = File.new(Rails.root.join('test/fixtures/product_tests/cms111v3_catiii.xml'))
    Rack::Test::UploadedFile.new(xmlfile, 'application/xml')
  end

  def accepted_execution_show_attributes
    %w[state created_at]
  end

  def make_first_task_type(type)
    @first_task._type = type
    @first_task.save!
  end
end
