require 'test_helper'
class ChecklistCriteriaValidator < ActiveSupport::TestCase
  include ::Validators

  def setup
    product = FactoryBot.create(:product_static_bundle)
    @measure = Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE').first
    @checklist_test = product.product_tests.build({ name: 'c1 visual', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, ChecklistTest)
    @checklist_test.save!
    @validator = ChecklistCriteriaValidator.new(@checklist_test)

    @options = { start_time: Date.new(2012, 1, 1), end_time: Date.new(2012, 12, 31) }
  end

  def setup_sdc(definition, status, attribute_name, negated_valueset, recorded_result, attribute_code)
    source_criteria = { 'sdc' => { 'definition' => definition,
                                   'status' => status,
                                   'code_list_id' => '1.3.4.5',
                                   'attributes' => [{ 'attribute_name' => attribute_name }] } }
    @measure[:source_data_criteria] = source_criteria
    @measure.save
    @checklist_test.checked_criteria.destroy_all
    @checklist_test.checked_criteria.new(attribute_index: 0,
                                         code: '1234',
                                         recorded_result: recorded_result,
                                         attribute_code: attribute_code,
                                         negated_valueset: negated_valueset,
                                         measure_id: @measure._id,
                                         passed_qrda: nil,
                                         source_data_criteria: 'sdc')
    @checklist_test.save
  end

  TEST_ARRAY = [['adverse_event', nil, 'relevantPeriod', false, '20170503000000', nil, 'QDM::AdverseEvent', false],
                ['allergy_intolerance', nil, 'authorDatetime', false, '20170503000000', nil, 'QDM::AllergyIntolerance', false],
                ['allergy_intolerance', nil, 'prevalencePeriod', false, '20170503000000', nil, 'QDM::AllergyIntolerance', false],
                ['assessment', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::AssessmentPerformed', false],
                ['assessment', 'performed', 'negationRationale', false, nil, '1234', 'QDM::AssessmentPerformed', true],
                ['assessment', 'performed', 'result', false, '20170503000000', nil, 'QDM::AssessmentPerformed', false],
                ['communication_from_patient_to_provider', nil, 'authorDatetime', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                ['communication_from_provider_to_patient', nil, 'authorDatetime', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                ['communication_from_provider_to_patient', nil, 'negationRationale', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                ['communication_from_provider_to_provider', nil, 'authorDatetime', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                ['communication_from_provider_to_provider', nil, 'negationRationale', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                ['communication_from_provider_to_provider', nil, 'relatedTo', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                ['device', 'applied', 'authorDatetime', false, '20170503000000', nil, 'QDM::DeviceApplied', false],
                ['device', 'applied', 'negationRationale', false, nil, '1234', 'QDM::DeviceApplied', true],
                ['device', 'applied', 'relevantPeriod', false, '20170503000000', nil, 'QDM::DeviceApplied', false],
                ['device', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::DeviceOrder', false],
                ['device', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::DeviceOrder', true],
                ['diagnosis', nil, 'anatomicalLocationSite', false, nil, '1234', 'QDM::Diagnosis', false],
                ['diagnosis', nil, 'authorDatetime', false, '20170503000000', nil, 'QDM::Diagnosis', false],
                ['diagnosis', nil, 'prevalencePeriod', false, '20170503000000', nil, 'QDM::Diagnosis', false],
                ['diagnosis', nil, 'severity', false, nil, '1234', 'QDM::Diagnosis', false],
                ['diagnostic_study', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::DiagnosticStudyOrder', false],
                ['diagnostic_study', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::DiagnosticStudyOrder', true],
                ['diagnostic_study', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::DiagnosticStudyPerformed', false],
                ['diagnostic_study', 'performed', 'components', false, nil, '1234', 'QDM::DiagnosticStudyPerformed', false],
                ['diagnostic_study', 'performed', 'negationRationale', false, nil, '1234', 'QDM::DiagnosticStudyPerformed', true],
                ['diagnostic_study', 'performed', 'reason', false, nil, '1234', 'QDM::DiagnosticStudyPerformed', false],
                ['diagnostic_study', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::DiagnosticStudyPerformed', false],
                ['diagnostic_study', 'performed', 'result', false, nil, '1234', 'QDM::DiagnosticStudyPerformed', false],
                ['encounter', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::EncounterOrder', false],
                ['encounter', 'performed', 'admissionSource', false, nil, '1234', 'QDM::EncounterPerformed', false],
                ['encounter', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::EncounterPerformed', false],
                ['encounter', 'performed', 'diagnoses', false, nil, '1234', 'QDM::EncounterPerformed'],
                ['encounter', 'performed', 'dischargeDisposition', false, nil, '1234', 'QDM::EncounterPerformed', false],
                ['encounter', 'performed', 'facilityLocations', false, nil, '1234', 'QDM::EncounterPerformed', false],
                ['encounter', 'performed', 'principalDiagnosis', false, nil, '1234', 'QDM::EncounterPerformed', false],
                ['encounter', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::EncounterPerformed', false],
                ['immunization', 'administered', 'authorDatetime', false, '20170503000000', nil, 'QDM::ImmunizationAdministered', false],
                ['immunization', 'administered', 'negationRationale', false, nil, '1234', 'QDM::ImmunizationAdministered', true],
                ['intervention', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::InterventionOrder', false],
                ['intervention', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::InterventionOrder', true],
                ['intervention', 'ordered', 'reason', false, nil, '1234', 'QDM::InterventionOrder', false],
                ['intervention', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::InterventionPerformed', false],
                ['intervention', 'performed', 'negationRationale', false, nil, '1234', 'QDM::InterventionPerformed', true],
                ['intervention', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::InterventionPerformed', false],
                ['laboratory_test', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::LaboratoryTestOrder', false],
                ['laboratory_test', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::LaboratoryTestOrder', true],
                ['laboratory_test', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false],
                ['laboratory_test', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false],
                ['laboratory_test', 'performed', 'result', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false],
                ['laboratory_test', 'performed', 'resultDatetime', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false],
                ['medication', 'active', 'relevantPeriod', false, '20170503000000', nil, 'QDM::MedicationActive', false],
                ['medication', 'administered', 'authorDatetime', false, '20170503000000', nil, 'QDM::MedicationAdministered', false],
                ['medication', 'administered', 'negationRationale', false, nil, '1234', 'QDM::MedicationAdministered', true],
                ['medication', 'administered', 'relevantPeriod', false, '20170503000000', nil, 'QDM::MedicationAdministered', false],
                ['medication', 'administered', 'route', false, nil, '1234', 'QDM::MedicationAdministered', false],
                ['medication', 'discharge', 'authorDatetime', false, '20170503000000', nil, 'QDM::MedicationDischarge', false],
                ['medication', 'discharge', 'negationRationale', false, nil, '1234', 'QDM::MedicationDischarge', true],
                ['medication', 'dispensed', 'authorDatetime', false, '20170503000000', nil, 'QDM::MedicationDispensed', false],
                ['medication', 'dispensed', 'negationRationale', false, nil, '1234', 'QDM::MedicationDispensed', true],
                ['medication', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                ['medication', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::MedicationOrder', true],
                # ['medication', 'ordered', 'relevantPeriod', false, '20170503000000', nil, 'QDM::MedicationOrder', false], # The effective time can be the AuthorTime or Relevant period
                ['medication', 'ordered', 'route', false, nil, '1234', 'QDM::MedicationOrder', false],
                ['physical_exam', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::PhysicalExamPerformed', false],
                ['physical_exam', 'performed', 'result', false, '20170503000000', nil, 'QDM::PhysicalExamPerformed', false],
                ['procedure', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::ProcedureOrder', false],
                ['procedure', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::ProcedurePerformed', false],
                ['procedure', 'performed', 'negationRationale', false, nil, '1234', 'QDM::ProcedurePerformed', true],
                ['procedure', 'performed', 'ordinality', false, nil, '1234', 'QDM::ProcedurePerformed', false],
                ['procedure', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::ProcedurePerformed', false],
                ['substance', 'administered', 'relevantPeriod', false, '20170503000000', nil, 'QDM::SubstanceAdministered', false]].freeze

  def test_validate_good_files
    TEST_ARRAY.each do |ta|
      setup_sdc(ta[0], ta[1], ta[2], ta[3], ta[4], ta[5])

      doc = if ta[2] == 'negationRationale'
              File.open("test/fixtures/qrda/checklist/#{ta[0]}_#{ta[1]}_negation_code.xml") { |f| Nokogiri::XML(f) }
            else
              File.open("test/fixtures/qrda/checklist/#{ta[0]}_#{ta[1]}_good.xml") { |f| Nokogiri::XML(f) }
            end
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
      @validator.validate(doc)

      assert @checklist_test.checked_criteria.first[:passed_qrda], "should pass with a good file for #{ta[0]} #{ta[1]} with a #{ta[2]}"
    end
  end

  def test_validate_bad_files
    TEST_ARRAY.each do |ta|
      setup_sdc(ta[0], ta[1], ta[2], ta[3], ta[4], ta[5])

      doc = File.open("test/fixtures/qrda/checklist/#{ta[0]}_#{ta[1]}_#{ta[2]}_bad.xml") { |f| Nokogiri::XML(f) }
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')

      @validator.validate(doc)
      assert_nil @checklist_test.checked_criteria.first[:passed_qrda], "should fail with a bad file for #{ta[0]} #{ta[1]} with a #{ta[2]}"
    end
  end
end
