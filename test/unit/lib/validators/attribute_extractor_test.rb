require 'test_helper'
class AttributeExtractorTest < ActiveSupport::TestCase
  def setup
    @object = Object.new
    @object.extend(Validators::AttributeExtractor)
  end

  def create_source_data_criteria(definition, attribute_name, attribute_valueset = nil)
    source_criteria = { 'title' => 'Title', 'definition' => definition,
                        'attributes' => [{ 'attribute_name' => attribute_name, 'attribute_valueset' => attribute_valueset }] }
    @object.instance_variable_set(:@source_criteria, source_criteria)
  end

  def create_checked_criteria(code, recorded_result)
    checked_criteria = { 'attribute_index' => 0, 'code' => code, 'recorded_result' => recorded_result }
    @object.instance_variable_set(:@checked_criteria, checked_criteria)
  end

  def create_template(template)
    @object.instance_variable_set(:@template, template)
  end

  def find_attribute_in_fixture(file, code, recorded_result)
    doc = get_document(file)
    @object.find_attribute_values(doc.xpath("//*[@code='#{code}']").first.parent, recorded_result, 0)
  end

  def test_encounter_order_author_datetime
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_order_author_datetime.xml')).read
    code = '19951005'
    recorded_result = 'Date Time Entered'
    create_source_data_criteria('encounter', 'authorDatetime')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.22')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_encounter_order_author_datetime_missing
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_order_no_author_datetime.xml')).read
    code = '19951005'
    recorded_result = 'Date Time Entered'
    create_source_data_criteria('encounter', 'authorDatetime')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.22')
    assert_equal false, find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_encounter_performed_diagnosis
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_performed.xml')).read
    code = '32485007'
    recorded_result = 'V30.00'
    create_source_data_criteria('encounter', 'diagnoses')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.23')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_encounter_performed_relevant_period_missing
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_performed_missing_relevant_period.xml')).read
    code = '32485007'
    recorded_result = 'Date Time Entered'
    create_source_data_criteria('encounter', 'relevantPeriod')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.23')
    assert_equal false, find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_encounter_performed_principal_diagnosis
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_performed.xml')).read
    code = '32485007'
    recorded_result = '312342009'
    create_source_data_criteria('encounter', 'principalDiagnosis')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.23')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_encounter_performed_discharge_disposition
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_performed.xml')).read
    code = '32485007'
    recorded_result = '306701001'
    create_source_data_criteria('encounter', 'dischargeDisposition')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.23')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_encounter_performed_facility_location
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_performed.xml')).read
    code = '32485007'
    recorded_result = '4525004'
    create_source_data_criteria('encounter', 'facilityLocations')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.23')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_encounter_performed_admission_source
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_performed.xml')).read
    code = '32485007'
    recorded_result = '18095007'
    create_source_data_criteria('encounter', 'admissionSource')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.23')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_communication_from_provider_to_provider
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'communication.xml')).read
    code = '371530004'
    recorded_result = 'Date Time Entered'
    create_source_data_criteria('communication_from_provider_to_provider', 'authorDatetime')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.4')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_communication_from_provider_to_provider_related_to
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'communication.xml')).read
    code = '371530004'
    recorded_result = 'Related to Referal'
    create_source_data_criteria('communication_from_provider_to_provider', 'relatedTo')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.4')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_diagnosis_prevalence_period
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'diagnosis.xml')).read
    code = '298049006'
    recorded_result = 'Date Time Entered'
    create_source_data_criteria('diagnosis', 'prevalencePeriod')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.135')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_diagnosis_anatomical_location_site
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'diagnosis.xml')).read
    code = '298049006'
    recorded_result = '24028007'
    create_source_data_criteria('diagnosis', 'anatomicalLocationSite')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.135')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_diagnosis_severity
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'diagnosis.xml')).read
    code = '298049006'
    recorded_result = '24484000'
    create_source_data_criteria('diagnosis', 'severity')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.135')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_diagnosis_severity_wrong_code
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'diagnosis.xml')).read
    code = '298049006'
    recorded_result = '24484001'
    create_source_data_criteria('diagnosis', 'severity')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.135')
    assert_equal false, find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_lab_test_performed_result_time
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'lab_test_performed.xml')).read
    code = '18261-8'
    recorded_result = 'Date Time Entered'
    create_source_data_criteria('laboratory_test', 'resultDatetime')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.38')
    assert_equal true, find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_procedure_ordinality
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'procedure_performed.xml')).read
    code = '29819009'
    recorded_result = '63161005'
    create_source_data_criteria('procedure', 'ordinality')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.22.4.14')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_medication_route
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'medication_route.xml')).read
    code = '1658720'
    recorded_result = '418114005'
    create_source_data_criteria('medication', 'route')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.42')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def test_diagnostic_study_components
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'diagnostic_study_components.xml')).read
    code = '32451-7'
    recorded_result = '312903003'
    create_source_data_criteria('diagnostic_study', 'components')
    create_checked_criteria(code, recorded_result)
    create_template('2.16.840.1.113883.10.20.24.3.18')
    assert find_attribute_in_fixture(file, code, recorded_result)
  end

  def get_document(input)
    doc = Nokogiri::XML(input)
    doc.root.add_namespace_definition('', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
    doc
  end
end
