require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  
  setup do
    collection_fixtures('records', '_id')
    collection_fixtures('users')
    @pi = HealthDataStandards::Import::C32::PatientImporter.instance
    sign_in :user, User.first(:conditions => {:email => 'bobby@tables.org'})
    get(:show, {:id => '4dcbecdb431a5f5878000004', :format => 'c32'})
    assert_response :success
    doc = Nokogiri::XML(response.body)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    @patient = @pi.parse_c32(doc)
  end
  
  test "results" do
    result = @patient.results[0]
    assert_equal 1257901150, result.time
    assert_equal({"SNOMED-CT" => ["439958008"]}, result.codes)
  end
end