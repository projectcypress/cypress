require 'test_helper'

class ServicesControllerTest < ActionController::TestCase
  # This test is expected to break when the validation xsd is updated to the 2011 schema
  test "validation for PQRI upload" do
    pqri_path = "test/fixtures/pqri/pqri_valid.xml"
    
    post :validate_pqri, {:pqri => fixture_file_upload(pqri_path, "text/xml")}
    assert_response :success
    
    assert assigns[:validation_errors].empty?
  end
  
  test "validation for PQRI upload with errors" do
    pqri_path = "test/fixtures/pqri/pqri_failing.xml"
    
    post :validate_pqri, {:pqri => fixture_file_upload(pqri_path, "text/xml")}
    assert_response :success
    
    assert assigns[:validation_errors].size > 0
  end
  
  test "validation requested with no PQRI uploaded" do
    get :validate_pqri
    assert_response :success
    
    assert_nil assigns[:validation_errors]
  end
end
