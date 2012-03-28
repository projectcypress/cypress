require 'test_helper'

class PatientsControllerTest < ActionController::TestCase
  
  setup do
    collection_fixtures('records', '_id')
    collection_fixtures('users')
    @pi = HealthDataStandards::Import::C32::PatientImporter.instance
    sign_in :user, User.first(:conditions => {:email => 'bobby@tables.org'})
    get(:show, {:id => '4dcbecdb431a5f5878000004', :format => 'c32'})
    assert_response :success
    doc = Nokogiri::XML(response.body)
    puts doc
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    @patient = @pi.parse_c32(doc)
  end
  
  test "demographics" do
    sign_in :user, User.first(:conditions => {:email => 'bobby@tables.org'})
    get(:show, {:id => '4dcbecdb431a5f5878000004', :format => 'c32'})
    assert_response :success
    
    doc = Nokogiri::XML(response.body)
    
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = Record.new
    @pi.get_demographics(patient, doc)

    assert_equal 'Rosa', patient.first
    assert_equal 'Vasquez', patient.last
    assert_equal 'F', patient.gender
    assert_equal 345426614, patient.birthdate
  end
  
  test "encounters" do
    encounter = @patient.encounters[0]
    assert_equal 1267322332, encounter.time
    assert_equal({"CPT" => ["99201"]}, encounter.codes)
  end
  
  test "conditions" do
    condition = @patient.conditions[0]
    assert_equal 1269776601, condition.as_point_in_time
    assert_equal({"SNOMED-CT" => ["160603005"]}, condition.codes)
  end
  
  test "vitals" do
    vital = @patient.vital_signs[0]
    assert_equal 1266664414, vital.time
    assert_equal({"SNOMED-CT" => ["225171007"]}, vital.codes)
    assert_equal "26", vital.value[:scalar]
  end
  
  test "procedures" do
    procedure = @patient.procedures[0]
    assert_equal 1273150428, procedure.time
    assert_equal({"SNOMED-CT" => ["171055003"]}, procedure.codes)
  end

  test "immunizations" do
    immunization = @patient.immunizations[0]
    assert_equal 1264529050, immunization.time
    assert_equal({"RxNorm" => ["854931"]}, immunization.codes)
  end

  test "medications" do
    medication = @patient.medications[0]
    assert_equal 1271810257, medication.start_time
    assert_equal({"RxNorm" => ["105075"]}, medication.codes)
  end

  test "care goals" do
    care_goal = @patient.care_goals[0]
    assert_equal 1278043200, care_goal.time
    assert_equal({"CPT" => ["97804"]}, care_goal.codes)
  end

  test "social history" do
    social_history = @patient.social_history[0]
    assert_equal 1265778000, social_history.time
    assert_equal({"ICD-9-CM" => ["250"]}, social_history.codes)
  end
  
  test "medical equipment" do
    medical_equipment = @patient.medical_equipment[0]
    assert_equal 1279252800, medical_equipment.time
    assert_equal({"SNOMED-CT" => ["56961003"]}, medical_equipment.codes)
  end
end
