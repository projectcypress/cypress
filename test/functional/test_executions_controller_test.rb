require 'test_helper'

class TestExecutionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do

    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('measures','bundle_id')
    collection_fixtures('products','_id','vendor_id')
    collection_fixtures('product_tests','_id','product_id','bundle_id')
    collection_fixtures('users',"_id", "vendor_ids")
    collection_fixtures('records', '_id','bundle_id')
    
    @user = User.where({:first_name => 'bobby', :last_name => 'tables'}).first
    sign_in @user
  end
  


  test "show" do
      get :show, {id: TestExecution.first}
      assert_response :success
  end

  test "create" do
     pt1 = ProductTest.find("4f58f8de1d41c851eb000999")
     ex_count = TestExecution.where(:product_test_id => pt1.id).count

    qrda = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'), "application/xml")
    params = {product_test_id: pt1.id, test_execution: {results: qrda}}
    post(:create, params)
    assert_response 302

    assert_equal ex_count+1 , TestExecution.where(:product_test_id => pt1.id).count, "SHould increment the test executuon count"
    
  end

  test "destroy" do
    count = TestExecution.count
    test_execution = TestExecution.first
    post(:destroy, {:id => test_execution.id})  
    
    assert_response 302

    assert_equal count-1, TestExecution.count, "SHould decrament the test execution count"
  end

  test "download" do
     get :download, {id: TestExecution.first}
  end
end