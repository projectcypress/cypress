require 'test_helper'

class ProductTestsControllerTest < ActionController::TestCase
include Devise::TestHelpers

  setup do
    collection_fixtures('query_cache', 'test_id')
    collection_fixtures('users',"_id", "product_ids","product_test_ids")
    collection_fixtures('measures')
    collection_fixtures('products','_id','vendor_id', "user_id")
    collection_fixtures('records', '_id','test_id')
    collection_fixtures('product_tests', '_id','product_id',"user_id")
    collection_fixtures('patient_populations', '_id')
    collection_fixtures('test_executions', '_id','product_test_id')
    collection_fixtures2('patient_cache','value', '_id' ,'test_id', 'patient_id')
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.first(:conditions => {:username => 'bobbytables'})
    sign_in @user
  end

  test "show" do
    pt = ProductTest.find("4f58f8de1d41c851eb000478")
    ex  = TestExecution.where(:product_test_id => pt.id).first
    get :show, {:id => pt.id.to_s}

    assert_response :success
    assert assigns[:never_executed_before]
    assert assigns[:test].id    == pt.id
    assert assigns[:product].id == pt.product_id
    assert assigns[:vendor].id.to_s == "4f57a8791d41c851eb000002"
    assert assigns[:patients].count == 1
    assert assigns[:measures].count == 2
    assert assigns[:measures]['fail'].count == 2
    
    get :show, {:id => pt.id, :execution_id => ex.id}

    assert assigns[:current_execution].id == ex.id
    assert assigns[:test].id    == pt.id
    assert assigns[:product].id == pt.product_id
    assert assigns[:vendor].id.to_s == "4f57a8791d41c851eb000002"
    assert assigns[:patients].count == 1
    assert assigns[:measures].count == 2
    assert assigns[:measures]['fail'].count == 1
    assert assigns[:measures]['pass'].count == 1
    #test json here?
    #test pdf here?
  end

  test "new" do
    p1 = Product.first
    get :new, {:product => p1.id }

    assert_response :success
    assert !assigns[:test].nil?
    assert assigns[:product].id == p1.id
    assert assigns[:vendor].id  == p1.vendor.id
    assert assigns[:measures].count == 3
    assert assigns[:patient_populations].count == 3
    assert assigns[:measures_categories].count == 2
  end

  test "create" do
    Cypress::PopulationCloneJob.stubs(:create).returns("JOB_ID")
    pt1 = {:name =>'new1', :effective_date_end =>'12/21/2011' , :upload_format =>'c32', :patient_population =>'test'}
    pt2 = {:name =>'new2', :effective_date_end =>'12/21/2011' , :upload_format =>'ccr', :patient_population =>'test'}
    pt3 = {:name =>'new3', :effective_date_end =>'12/21/2011' , :upload_format =>'csv', :patient_population =>'test'}
    pt4 = {:name =>'new4', :effective_date_end =>'12/21/2011' , :upload_format =>'c32'}

    get :create, {:product_test => pt1, :download_filename => 'pt1file' }
    assert_response :redirect
    newTest = ProductTest.where({:name => 'new1'})
    assert newTest.count == 1
    assert newTest.first.download_filename == 'pt1file'

    get :create, {:product_test => pt2, :download_filename => 'pt2file', :patient_ids => ['19','20','21'] }
    assert_response :redirect
    assert ProductTest.where({:name => 'new2'}).count == 1

    get :create, {:product_test => pt3, :download_filename => 'pt3file', :patient_ids => ['19','20','21'] ,:population_description => 'minimal set',:population_name => 'minset'}
    assert_response :redirect
    assert ProductTest.where({:name => 'new3'}).count == 1
    assert PatientPopulation.where({:name => 'minset'}).count == 1

    get :create, {:product_test => pt4, :patient_ids => ['19','20','21'], :measure_ids => ["0013","0028","0421","" ] }
    assert_response :redirect
    assert ProductTest.where({:name => 'new4'}).count == 1
  end

  test "edit" do
    pt = ProductTest.first
    get :edit, {:id => pt.id}
    assert_response :success

    assert assigns[:test].id == pt.id
    assert assigns[:product].id == pt.product.id
    assert assigns[:vendor].id  == pt.product.vendor.id
    assert assigns[:effective_date] == pt.effective_date
  end

  test "update" do
    pt = ProductTest.first
    updated_attributes = {:name => 'Updated test name', :description => 'Updated Description'}
    get :update, {:id => pt.id, :product_test => updated_attributes}

    assert_response :redirect
    pt_updated = ProductTest.find(pt.id)
    assert pt_updated.name == 'Updated test name'
    assert pt_updated.description == 'Updated Description'
  end

  test "destroy" do
    pt = ProductTest.first
    ex = TestExecution.first

    get :destroy, {:id => pt.id, :execution_id => ex.id}

    assert_response :redirect
    destroyed = TestExecution.where(:id => ex.id)
    assert destroyed.count == 0

    get :destroy, {:id => pt.id}

    destroyed = ProductTest.where(:id => pt.id)
    assert destroyed.count == 0
  end

  test "period" do
    @request.accept = "text/javascript"
    get :period, {:effective_date => '12/21/2011'}

    assert_response :success
    assert assigns[:effective_date] == 1324443600
    assert assigns[:period_start]   == '2011-09-21 00:00:00 -0400'
  end

  test "process_pqri" do
    pt1 = ProductTest.find("4f58f8de1d41c851eb000478")
    pt2 = ProductTest.new
    pt3 = ProductTest.find("4fa3f10d824eb96b51000005")

    ex  = TestExecution.where(:product_test_id => pt1.id).first
    ex_count = TestExecution.where(:product_test_id => pt1.id).count
    baseline = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_baseline.xml'), "application/xml")
    pqri = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_failing.xml'), "application/xml")
    pqri_with_mapped_measures = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_with_mapped_measures.xml'), "application/xml")
    
    pt2.name = 'Product test with no executions'
    pt2.effective_date = 1324443600
    pt2.product_id = pt1.product_id
    pt2.user=@user
    pt2.save!

    pt3.name = 'Product test mapped measures'
    pt3.effective_date = 1324443600
    pt3.save!

    post :process_pqri, {:id => pt1.id.to_s , :product_test => {:pqri => pqri}, :execution_id => ex.id}
    assert_response :redirect
    ex_updated = TestExecution.find(ex.id)
    assert ex_updated.reported_results['0001']['denominator'] == 56
    assert TestExecution.where(:product_test_id => pt1.id).count == ex_count

    pqri = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_failing.xml'), "application/xml")    

    post :process_pqri, {:id => pt2.id , :product_test => {:pqri => pqri, :baseline => baseline}, :execution_id => {}}

    new_ex = TestExecution.where(:product_test_id => pt2.id).first
    assert new_ex.reported_results['0001']['denominator'] == 50
    assert TestExecution.where(:product_test_id => pt2.id).count == 1

    post :process_pqri, {:id => pt3.id , :product_test => {:pqri => pqri_with_mapped_measures}, :execution_id => {}}
    new_ex = TestExecution.where(:product_test_id => pt3.id).first

    assert new_ex.reported_results['0001']['denominator'] == 35
    assert new_ex.reported_results['0002']['denominator'] == 8
    assert TestExecution.where(:product_test_id => pt3.id).count == 1
  end

  test "download" do
    pt = ProductTest.find("4f58f8de1d41c851eb000478")

    get :download,{:id => pt.id , :format => 'csv' }
    assert_response :success, "Failed to download CSV file"
    flat_file = "patient_id,first name,last name,gender,race,ethnicity,birthdate\n21,Rachel,Mendez,M,White,Not Hispanic or Latino,06/08/1981\n"
    assert @response.body == flat_file , "Downloaded CSV file contents not correct"

    get :download,{:id => pt.id , :format => 'c32' }
    assert_response :success,"Failed to download C32 zip file"
    get :download,{:id => pt.id , :format => 'ccr' }
    assert_response :success,"Failed to download CCR zip file"
    get :download,{:id => pt.id , :format => 'html'}
    assert_response :success,"Failed to download HTML zip file"
  end
  
  test "add note" do
    assert ProductTest.find("4f58f8de1d41c851eb000478").notes.empty?

    post(:add_note, {:id => "4f58f8de1d41c851eb000478", :note => {:text => "This is notable"}})
    assert_response :redirect
    assert ProductTest.find("4f58f8de1d41c851eb000478").notes.count == 1
  end
  
  test "delete note" do
    test = ProductTest.find("4f6b78801d41c851eb0004a7")
    assert_equal test.notes.size, 1
    
    # BSONify the ID of the note connected to this ProductTest so that it's findable during deletion
    test.notes.first["_id"] = BSON::ObjectId.from_string(test.notes.first["_id"])
    test.save
    
    delete(:delete_note, {:id => "4f6b78801d41c851eb0004a7", "note" => {"id" => "4fa287f99e8f54e9e9000038"}})
    assert_response :redirect
    assert ProductTest.find('4f6b78801d41c851eb0004a7').notes.empty?
  end
end