require 'test_helper'

class PatientsControllerTest < ActionController::TestCase
  
  setup do
    collection_fixtures('records', '_id')
    collection_fixtures('users')
    @pi = QME::Importer::PatientImporter.instance
  end
  
  test "demographics" do
    sign_in :user, User.first(:conditions => {:email => 'bobby@tables.org'})
    get(:show, {:id => '4dcbecdb431a5f5878000004', :format => 'c32'})
    assert_response :success
    doc = Nokogiri::XML(response.body)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    parsed = {}
    @pi.get_demographics(parsed, doc)

    assert_equal 'Rosa', parsed['first']
    assert_equal 'Vasquez', parsed['last']
    assert_equal 'F', parsed['gender']
    assert_equal 345426614, parsed['birthdate']
  end
  
  test "encounters" do
    sign_in :user, User.first(:conditions => {:email => 'bobby@tables.org'})
    get(:show, {:id => '4dcbecdb431a5f5878000004', :format => 'c32'})
    assert_response :success
    doc = Nokogiri::XML(response.body)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = @pi.create_c32_hash(doc)
    encounter = patient[:encounters][0]
    assert_equal 1267322332, encounter.time
    assert_equal({"CPT" => ["99201"]}, encounter.codes)
  end
end
