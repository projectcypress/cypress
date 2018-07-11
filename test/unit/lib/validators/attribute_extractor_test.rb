require 'test_helper'
class AttributeExtractorTest < ActiveSupport::TestCase
  def setup
    @object = Object.new
    @object.extend(Validators::AttributeExtractor)
  end

  def test_start_datetime
    source_criteria = {  'title' => 'Decision to Admit to Hospital Inpatient',
                         'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.295',
                         'attributes' => [{ 'attribute_name' => 'authorDatetime', 'attribute_valueset' => nil }]
                      }
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_order_start_datetime.xml')).read
    code = '19951005'
    doc = get_document(file)
    assert @object.find_attribute_values(doc.xpath("//*[@code='#{code}']").first.parent, code, source_criteria, 0)
  end

  # def test_facility_location_departure_datetime
  #   source_criteria = {  'title' => 'Emergency Department Visit',
  #                        'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.292',
  #                        'field_values' => {
  #                          'FACILITY_LOCATION_DEPARTURE_DATETIME' => {
  #                            'type' => 'ANYNonNull'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_with_facility.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, nil, source_criteria)
  # end

  # def test_facility_location_arrival_datetime
  #   source_criteria = {  'title' => 'Emergency Department Visit',
  #                        'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.292',
  #                        'field_values' => {
  #                          'FACILITY_LOCATION_ARRIVAL_DATETIME' => {
  #                            'type' => 'ANYNonNull'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_with_facility.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, nil, source_criteria)
  # end

  # def test_admission_datetime
  #   source_criteria = {  'title' => 'Emergency Department Visit',
  #                        'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.292',
  #                        'field_values' => {
  #                          'ADMISSION_DATETIME' => {
  #                            'type' => 'ANYNonNull'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_with_facility.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, nil, source_criteria)
  # end

  # def test_discharge_datetime
  #   source_criteria = {  'title' => 'Emergency Department Visit',
  #                        'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.292',
  #                        'field_values' => {
  #                          'DISCHARGE_DATETIME' => {
  #                            'type' => 'ANYNonNull'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_with_facility.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, nil, source_criteria)
  # end

  # def test_length_of_stay
  #   source_criteria = {  'title' => 'Emergency Department Visit',
  #                        'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.292',
  #                        'field_values' => {
  #                          'LENGTH_OF_STAY' => {
  #                            'type' => 'ANYNonNull'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_with_facility.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, nil, source_criteria)
  # end

  # def test_facility_location
  #   source_criteria = {  'title' => 'Emergency Department Visit',
  #                        'code_list_id' => '2.16.840.1.113883.3.464.1003.101.12.1055',
  #                        'field_values' => {
  #                          'FACILITY_LOCATION' => {
  #                            'type' => 'CD',
  #                            'code_list_id' => '2.16.840.1.113883.3.464.1003.122.12.1003',
  #                            'title' => 'Ambulatory Grouping Value Set'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_with_facility_location.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, '255327002', source_criteria)
  # end

  # def test_discharge_status
  #   source_criteria = {  'title' => 'Encounter Inpatient',
  #                        'code_list_id' => '2.16.840.1.113883.3.666.5.307',
  #                        'field_values' => {
  #                          'DISCHARGE_STATUS' => {
  #                            'type' => 'CD',
  #                            'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.209',
  #                            'title' => 'Discharged to Home for Hospice Care'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_with_discharge_status.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, '306701001', source_criteria)
  # end

  # def test_principal_diagnosis
  #   source_criteria = {  'title' => 'Encounter Inpatient',
  #                        'code_list_id' => '2.16.840.1.113883.3.666.5.307',
  #                        'field_values' => {
  #                          'PRINCIPAL_DIAGNOSIS' => {
  #                            'type' => 'CD',
  #                            'code_list_id' => '2.16.840.1.113883.3.666.5.696',
  #                            'title' => 'Any infection Grouping Value Set'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_with_principal_diagnosis.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, '312342009', source_criteria)
  # end

  # def test_diagnosis
  #   source_criteria = {  'title' => 'Encounter Inpatient',
  #                        'code_list_id' => '2.16.840.1.113883.3.666.5.307',
  #                        'field_values' => {
  #                          'DIAGNOSIS' => {
  #                            'type' => 'CD',
  #                            'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.26',
  #                            'title' => 'Single Live Born Newborn Born in Hospital Grouping Value Set'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'encounter_with_diagnosis.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, 'V30.00', source_criteria)
  # end

  # def test_incision
  #   source_criteria = {  'title' => 'CABG Surgeries',
  #                        'code_list_id' => '2.16.840.1.113883.3.666.5.694',
  #                        'field_values' => {
  #                          'INCISION_DATETIME' => {
  #                            'type' => 'ANYNonNull'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'procedure_with_incision_ordinality.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, nil, source_criteria)
  # end

  # def test_procedure_ordinality
  #   source_criteria = {  'title' => 'CABG Surgeries',
  #                        'code_list_id' => '2.16.840.1.113883.3.666.5.694',
  #                        'field_values' => {
  #                          'ORDINALITY' => {
  #                            'type' => 'CD',
  #                            'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.14',
  #                            'title' => 'Principal'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'procedure_with_incision_ordinality.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, '63161005', source_criteria)
  # end

  # def test_ordinal
  #   source_criteria = {  'title' => 'CABG Surgeries',
  #                        'code_list_id' => '2.16.840.1.113883.3.666.5.694',
  #                        'field_values' => {
  #                          'ORDINAL' => {
  #                            'type' => 'CD',
  #                            'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.14',
  #                            'title' => 'Principal'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'procedure_with_incision_ordinality.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, '63161005', source_criteria)
  # end

  # def test_anatomical_location_site
  #   source_criteria = {  'title' => 'Unilateral Amputation Below or Above Knee, Unspecified Laterality',
  #                        'code_list_id' => '2.16.840.1.113883.3.464.1003.113.12.1059',
  #                        'field_values' => {
  #                          'ANATOMICAL_LOCATION_SITE' => {
  #                            'type' => 'CD',
  #                            'code_list_id' => '2.16.840.1.113883.3.464.1003.122.12.1035',
  #                            'title' => 'Right Grouping Value Set'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'diagnosis_anatomical_location.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, '24028007', source_criteria)
  # end

  # def test_laterality
  #   source_criteria = {  'title' => 'Unilateral Amputation Below or Above Knee, Unspecified Laterality',
  #                        'code_list_id' => '2.16.840.1.113883.3.464.1003.113.12.1059',
  #                        'field_values' => {
  #                          'LATERALITY' => {
  #                            'type' => 'CD',
  #                            'code_list_id' => '2.16.840.1.113883.3.464.1003.122.12.1035',
  #                            'title' => 'Right'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'diagnosis_laterality.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, '24028007', source_criteria)
  # end

  # def test_severity
  #   source_criteria = {  'title' => 'Left Ventricular Systolic Dysfunction',
  #                        'code_list_id' => '2.16.840.1.113883.3.526.3.1091',
  #                        'field_values' => {
  #                          'SEVERITY' => {
  #                            'type' => 'CD',
  #                            'code_list_id' => '2.16.840.1.113883.3.526.3.1092',
  #                            'title' => 'Moderate or Severe Grouping Value Set'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'diagnosis_severity.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, '24484000', source_criteria)
  # end

  # def test_route
  #   source_criteria = {  'title' => 'IV Antimicrobial medication',
  #                        'code_list_id' => '2.16.840.1.113883.3.666.5.765',
  #                        'field_values' => {
  #                          'ROUTE' => {
  #                            'type' => 'CD',
  #                            'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.222',
  #                            'title' => 'Intravenous route SNOMEDCT Value Set'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'medication_route.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, '418114005', source_criteria)
  # end

  # def test_fulfills
  #   source_criteria = {  'title' => 'Consultant Report',
  #                        'code_list_id' => '2.16.840.1.113883.3.464.1003.121.12.1006',
  #                        'field_values' => {
  #                          'FLFS' => {
  #                            'type' => 'FLFS',
  #                            'reference' => 'OccurrenceA_Referral_InterventionPerformed_40280381_3d61_56a7_013e_7aa509fd625d',
  #                            'mood' => ''
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'communication_fulfills.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, '418114005', source_criteria)
  # end

  # def test_cumulative_medication_duration
  #   source_criteria = {  'title' => '"Medication, Active: ADHD Medications',
  #                        'code_list_id' => '2.16.840.1.113883.3.464.1003.196.12.1171',
  #                        'field_values' => {
  #                          'CUMULATIVE_MEDICATION_DURATION' => {
  #                            'type' => 'ANYNonNull'
  #                          }
  #                        } }
  #   file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'medication_with_cmd.xml')).read
  #   doc = get_document(file)
  #   assert @object.find_attribute_values(doc.xpath("//*[@sdtc:valueSet='#{source_criteria['code_list_id']}']").first.parent, nil, source_criteria)
  # end

  def get_document(input)
    doc = Nokogiri::XML(input)
    doc.root.add_namespace_definition('', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
    doc
  end
end
