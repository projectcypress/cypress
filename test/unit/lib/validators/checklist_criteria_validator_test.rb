require 'test_helper'
class ChecklistCriteriaValidator < ActiveSupport::TestCase
  include ::Validators

  def setup
    product = FactoryBot.create(:product_static_bundle)
    @measure = Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE').first
    @checklist_test = product.product_tests.build({ name: 'c1 visual', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, ChecklistTest)
    @checklist_test.save!
    @validator = ChecklistCriteriaValidator.new(@checklist_test)

    bd = 75.years.ago
    @qdm_patient = QDM::Patient.new(birthDatetime: bd)
    @qdm_patient.extendedData = { 'medical_record_number' => '123' }
    @qdm_patient.dataElements << QDM::PatientCharacteristicBirthdate.new(birthDatetime: bd)
    @qdm_patient.dataElements << QDM::PatientCharacteristicRace.new(dataElementCodes: [QDM::Code.new('2106-3', '2.16.840.1.113883.6.238', 'White', 'Race & Ethnicity - CDC')])
    @qdm_patient.dataElements << QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [QDM::Code.new('2186-5', '2.16.840.1.113883.6.238', 'Not Hispanic or Latino', 'Race & Ethnicity - CDC')])
    @qdm_patient.dataElements << QDM::PatientCharacteristicSex.new(dataElementCodes: [QDM::Code.new('M', '2.16.840.1.113883.12.1', 'Male', 'Administrative sex (HL7)')])
    address = CQM::Address.new(
      use: 'B',
      street: ['123 Main Lane'],
      city: 'Portland',
      state: 'Maine',
      zip: '99999',
      country: 'ZZ'
    )
    telecom = CQM::Telecom(
      use: 'HP',
      value: '555-555-5555'
    )
    @cqm_patient = CQM::Patient.new(givenNames: %w['First Middle'], familyName: 'Family', bundleId: '1', addresses: [address], telecoms: [telecom])
    @options = { start_time: Date.new(2012, 1, 1), end_time: Date.new(2012, 12, 31), patient_addresses: [address], patient_telecoms: [telecom] }
  end

  def setup_sdc(data_type, attribute_name, negated_valueset, recorded_result, attribute_code)
    data_type.codeListId = '1.3.4.5'
    atts = data_type.attributes.slice('qdmCategory', 'qdmStatus', '_type', 'hqmfOid', 'codeListId')
    atts['dataElementAttributes'] = [{ 'attribute_name' => attribute_name }]
    @checklist_test.checked_criteria.destroy_all
    @checklist_test.checked_criteria.new(attribute_index: 0,
                                         code: '1234',
                                         recorded_result: recorded_result,
                                         attribute_code: attribute_code,
                                         negated_valueset: negated_valueset,
                                         measure_id: @measure._id,
                                         passed_qrda: nil,
                                         source_data_criteria: atts)
    @checklist_test.save
  end

  TEST_ARRAY = [['adverse_event', nil, 'authorDatetime', false, '20170503000000', nil, 'QDM::AdverseEvent', false],
                ['adverse_event', nil, 'relevantPeriod', false, '20170503000000', nil, 'QDM::AdverseEvent', false],
                ['adverse_event', nil, 'severity', false, '20170503000000', nil, 'QDM::AdverseEvent'],
                ['adverse_event', nil, 'facilityLocation', false, '20170503000000', nil, 'QDM::AdverseEvent'],
                ['adverse_event', nil, 'type', false, '20170503000000', nil, 'QDM::AdverseEvent'],

                ['allergy_intolerance', nil, 'authorDatetime', false, '20170503000000', nil, 'QDM::AllergyIntolerance', false],
                ['allergy_intolerance', nil, 'prevalencePeriod', false, '20170503000000', nil, 'QDM::AllergyIntolerance', false],
                # ['allergy_intolerance', nil, 'type', false, '20170503000000', nil, 'QDM::AllergyIntolerance'], # Not currently in cqm-reports
                # ['allergy_intolerance', nil, 'severity', false, '20170503000000', nil, 'QDM::AllergyIntolerance'], # Not currently in cqm-reports

                ['assessment', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::AssessmentOrder', true],
                ['assessment', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::AssessmentOrder', false],
                ['assessment', 'ordered', 'reason', false, nil, '1234', 'QDM::AssessmentOrder', false],

                ['assessment', 'performed', 'negationRationale', false, nil, '1234', 'QDM::AssessmentPerformed', true],
                ['assessment', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::AssessmentPerformed', false],
                ['assessment', 'performed', 'reason', false, '20170503000000', nil, 'QDM::AssessmentPerformed', false],
                ['assessment', 'performed', 'method', false, '20170503000000', nil, 'QDM::AssessmentPerformed', false],
                ['assessment', 'performed', 'result', false, '20170503000000', nil, 'QDM::AssessmentPerformed', false],
                ['assessment', 'performed', 'components', false, '20170503000000', nil, 'QDM::AssessmentPerformed', false],
                # ['assessment', 'performed', 'relatedTo', false, '20170503000000', nil, 'QDM::AssessmentPerformed', false], # Not currently in patient generator

                ['assessment', 'recommended', 'negationRationale', false, nil, '1234', 'QDM::AssessmentRecommended', true],
                ['assessment', 'recommended', 'authorDatetime', false, '20170503000000', nil, 'QDM::AssessmentRecommended', false],
                ['assessment', 'recommended', 'reason', false, nil, '1234', 'QDM::AssessmentRecommended', false],

                ['communication', 'performed', 'negationRationale', false, nil, '1234', 'QDM::CommunicationPerformed', true],
                ['communication', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::CommunicationPerformed', false],
                ['communication', 'performed', 'category', false, nil, '1234', 'QDM::CommunicationPerformed', false],
                ['communication', 'performed', 'medium', false, nil, '1234', 'QDM::CommunicationPerformed', false],
                ['communication', 'performed', 'sender', false, nil, '1234', 'QDM::CommunicationPerformed', false],
                # ['communication', 'performed', 'recipient', false, nil, '1234', 'QDM::CommunicationPerformed', false], # Not currently in patient generator
                # ['communication', 'performed', 'relatedTo', false, '20170503000000', nil, 'QDM::CommunicationPerformed', false], # Not currently in patient generator
                ['communication', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::CommunicationPerformed', false],

                ['device', 'applied', 'negationRationale', false, nil, '1234', 'QDM::DeviceApplied', true],
                ['device', 'applied', 'authorDatetime', false, '20170503000000', nil, 'QDM::DeviceApplied', false],
                ['device', 'applied', 'relevantPeriod', false, '20170503000000', nil, 'QDM::DeviceApplied', false],
                ['device', 'applied', 'reason', false, nil, '1234', 'QDM::DeviceApplied', false],
                ['device', 'applied', 'anatomicalLocationSite', false, nil, '1234', 'QDM::DeviceApplied', false],

                ['device', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::DeviceOrder', true],
                ['device', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::DeviceOrder', false],
                ['device', 'ordered', 'reason', false, nil, '1234', 'QDM::DeviceOrder', false],

                ['device', 'recommended', 'negationRationale', false, nil, '1234', 'QDM::DeviceRecommended', true],
                ['device', 'recommended', 'authorDatetime', false, '20170503000000', nil, 'QDM::DeviceRecommended', false],
                ['device', 'recommended', 'reason', false, nil, '1234', 'QDM::DeviceRecommended', false],

                ['diagnosis', nil, 'authorDatetime', false, '20170503000000', nil, 'QDM::Diagnosis', false],
                ['diagnosis', nil, 'prevalencePeriod', false, '20170503000000', nil, 'QDM::Diagnosis', false],
                ['diagnosis', nil, 'anatomicalLocationSite', false, nil, '1234', 'QDM::Diagnosis', false],
                ['diagnosis', nil, 'severity', false, nil, '1234', 'QDM::Diagnosis', false],

                ['diagnostic_study', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::DiagnosticStudyOrder', true],
                ['diagnostic_study', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::DiagnosticStudyOrder', false],
                ['diagnostic_study', 'ordered', 'reason', false, nil, '1234', 'QDM::DiagnosticStudyOrder', false],

                ['diagnostic_study', 'performed', 'negationRationale', false, nil, '1234', 'QDM::DiagnosticStudyPerformed', true],
                ['diagnostic_study', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::DiagnosticStudyPerformed', false],
                ['diagnostic_study', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::DiagnosticStudyPerformed', false],
                ['diagnostic_study', 'performed', 'reason', false, nil, '1234', 'QDM::DiagnosticStudyPerformed', false],
                ['diagnostic_study', 'performed', 'result', false, nil, '1234', 'QDM::DiagnosticStudyPerformed', false],
                # ['diagnostic_study', 'performed', 'resultDatetime', false, '20170503000000', nil, 'QDM::DiagnosticStudyPerformed', false], # Cannot selective remove resultDatetime
                ['diagnostic_study', 'performed', 'status', false, nil, '1234', 'QDM::DiagnosticStudyPerformed', false],
                ['diagnostic_study', 'performed', 'method', false, nil, '1234', 'QDM::DiagnosticStudyPerformed', false],
                ['diagnostic_study', 'performed', 'facilityLocation', false, nil, '1234', 'QDM::DiagnosticStudyPerformed', false],
                ['diagnostic_study', 'performed', 'components', false, nil, '1234', 'QDM::DiagnosticStudyPerformed', false],

                ['diagnostic_study', 'recommended', 'negationRationale', false, nil, '1234', 'QDM::DiagnosticStudyRecommended', true],
                ['diagnostic_study', 'recommended', 'authorDatetime', false, '20170503000000', nil, 'QDM::DiagnosticStudyRecommended', false],

                ['encounter', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::EncounterOrder', true],
                ['encounter', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::EncounterOrder', false],
                ['encounter', 'ordered', 'reason', false, nil, '1234', 'QDM::EncounterOrder', false],
                ['encounter', 'ordered', 'facilityLocation', false, nil, '1234', 'QDM::EncounterOrder', false],

                ['encounter', 'performed', 'negationRationale', false, nil, '1234', 'QDM::EncounterPerformed', true],
                ['encounter', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::EncounterPerformed', false],
                ['encounter', 'performed', 'admissionSource', false, nil, '1234', 'QDM::EncounterPerformed', false],
                ['encounter', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::EncounterPerformed', false],
                ['encounter', 'performed', 'dischargeDisposition', false, nil, '1234', 'QDM::EncounterPerformed', false],
                ['encounter', 'performed', 'facilityLocations', false, nil, '1234', 'QDM::EncounterPerformed', false],
                ['encounter', 'performed', 'diagnoses', false,  nil, '1234', 'QDM::EncounterPerformed'],
                ['encounter', 'performed', 'principalDiagnosis', false, nil, '1234', 'QDM::EncounterPerformed', false],
                # ['encounter', 'performed', 'lengthOfStay', false, '2', nil, 'QDM::EncounterPerformed'], # Not currently in patient generator

                ['encounter', 'recommended', 'negationRationale', false, nil, '1234', 'QDM::EncounterRecommended', true],
                ['encounter', 'recommended', 'authorDatetime', false, '20170503000000', nil, 'QDM::EncounterRecommended', false],
                ['encounter', 'recommended', 'facilityLocation', false, nil, '1234', 'QDM::EncounterRecommended', false],
                ['encounter', 'recommended', 'reason', false, nil, '1234', 'QDM::EncounterRecommended', false],

                ['family_history', nil, 'authorDatetime', false, '20170503000000', nil, 'QDM::FamilyHistory', false],

                ['immunization', 'administered', 'negationRationale', false, nil, '1234', 'QDM::ImmunizationAdministered', true],
                ['immunization', 'administered', 'authorDatetime', false, '20170503000000', nil, 'QDM::ImmunizationAdministered', false],
                ['immunization', 'administered', 'reason', false, nil, '1234', 'QDM::ImmunizationAdministered', false],
                ['immunization', 'administered', 'dosage', false, nil, '1234', 'QDM::ImmunizationAdministered', false],
                ['immunization', 'administered', 'route', false, nil, '1234', 'QDM::ImmunizationAdministered', false],

                ['immunization', 'order', 'negationRationale', false, nil, '1234', 'QDM::ImmunizationOrder', true],
                ['immunization', 'order', 'activeDatetime', false, '20170503000000', nil, 'QDM::ImmunizationOrder', false],
                ['immunization', 'order', 'authorDatetime', false, '20170503000000', nil, 'QDM::ImmunizationOrder', false],
                ['immunization', 'order', 'dosage', false, '20170503000000', nil, 'QDM::ImmunizationOrder', false],
                ['immunization', 'order', 'supply', false, '20170503000000', nil, 'QDM::ImmunizationOrder', false],
                ['immunization', 'order', 'route', false, nil, '1234', 'QDM::ImmunizationOrder', false],
                ['immunization', 'order', 'reason', false, nil, '1234', 'QDM::ImmunizationOrder', false],

                ['intervention', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::InterventionOrder', true],
                ['intervention', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::InterventionOrder', false],
                ['intervention', 'ordered', 'reason', false, nil, '1234', 'QDM::InterventionOrder', false],

                ['intervention', 'performed', 'negationRationale', false, nil, '1234', 'QDM::InterventionPerformed', true],
                ['intervention', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::InterventionPerformed', false],
                ['intervention', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::InterventionPerformed', false],
                ['intervention', 'performed', 'reason', false, nil, '1234', 'QDM::InterventionPerformed', false],
                ['intervention', 'performed', 'result', false, nil, '1234', 'QDM::InterventionPerformed', false],
                ['intervention', 'performed', 'status', false, nil, '1234', 'QDM::InterventionPerformed', false],

                ['intervention', 'recommended', 'negationRationale', false, nil, '1234', 'QDM::InterventionRecommended', true],
                ['intervention', 'recommended', 'authorDatetime', false, '20170503000000', nil, 'QDM::InterventionRecommended', false],
                ['intervention', 'recommended', 'reason', false, nil, '1234', 'QDM::InterventionRecommended', false],

                ['laboratory_test', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::LaboratoryTestOrder', true],
                ['laboratory_test', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::LaboratoryTestOrder', false],
                ['laboratory_test', 'ordered', 'reason', false, nil, '1234', 'QDM::LaboratoryTestOrder', false],

                ['laboratory_test', 'performed', 'negationRationale', false, nil, '1234', 'QDM::LaboratoryTestPerformed', true],
                ['laboratory_test', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false],
                ['laboratory_test', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false],
                ['laboratory_test', 'performed', 'status', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false],
                ['laboratory_test', 'performed', 'method', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false],
                ['laboratory_test', 'performed', 'result', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false],
                # resultDatetime cannot be confirmed in the negative tests, since if a resultDatetime isn't include, we will then export the authorDatetime or relevantPeriod in its place
                # ['laboratory_test', 'performed', 'resultDatetime', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false],
                ['laboratory_test', 'performed', 'reason', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false],
                # ['laboratory_test', 'performed', 'referenceRange', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false], # Not currently in cqm-reports
                ['laboratory_test', 'performed', 'components', false, '20170503000000', nil, 'QDM::LaboratoryTestPerformed', false],

                ['laboratory_test', 'recommended', 'negationRationale', false, nil, '1234', 'QDM::LaboratoryTestRecommended', true],
                ['laboratory_test', 'recommended', 'authorDatetime', false, '20170503000000', nil, 'QDM::LaboratoryTestRecommended', false],
                ['laboratory_test', 'recommended', 'reason', false, nil, '1234', 'QDM::LaboratoryTestRecommended', false],

                ['medication', 'active', 'relevantPeriod', false, '20170503000000', nil, 'QDM::MedicationActive', false],
                ['medication', 'active', 'dosage', false, '20170503000000', nil, 'QDM::MedicationActive', false],
                # ['medication', 'active', 'frequency', false, nil, '1234', 'QDM::MedicationActive', false], # roundtrip does not work with code specified in patient generator
                ['medication', 'active', 'route', false, nil, '1234', 'QDM::MedicationActive', false],

                ['medication', 'administered', 'negationRationale', false, nil, '1234', 'QDM::MedicationAdministered', true],
                ['medication', 'administered', 'authorDatetime', false, '20170503000000', nil, 'QDM::MedicationAdministered', false],
                ['medication', 'administered', 'relevantPeriod', false, '20170503000000', nil, 'QDM::MedicationAdministered', false],
                ['medication', 'administered', 'dosage', false, '20170503000000', nil, 'QDM::MedicationAdministered', false],
                # ['medication', 'administered', 'frequency', false, '20170503000000', nil, 'QDM::MedicationAdministered', false], # roundtrip does not work with code specified in patient generator
                ['medication', 'administered', 'route', false, nil, '1234', 'QDM::MedicationAdministered', false],
                ['medication', 'administered', 'reason', false, '20170503000000', nil, 'QDM::MedicationAdministered', false],

                ['medication', 'discharge', 'negationRationale', false, nil, '1234', 'QDM::MedicationDischarge', true],
                ['medication', 'discharge', 'authorDatetime', false, '20170503000000', nil, 'QDM::MedicationDischarge', false],
                ['medication', 'discharge', 'refills', false, '20170503000000', nil, 'QDM::MedicationDischarge', false],
                ['medication', 'discharge', 'dosage', false, '20170503000000', nil, 'QDM::MedicationDischarge', false],
                ['medication', 'discharge', 'supply', false, '20170503000000', nil, 'QDM::MedicationDischarge', false],
                # ['medication', 'discharge', 'frequency', false, nil, '1234', 'QDM::MedicationDischarge', false], # roundtrip does not work with code specified in patient generator
                ['medication', 'discharge', 'daysSupplied', false, '20170503000000', nil, 'QDM::MedicationDischarge', false],
                ['medication', 'discharge', 'route', false, nil, '1234', 'QDM::MedicationDischarge', false],

                ['medication', 'dispensed', 'negationRationale', false, nil, '1234', 'QDM::MedicationDispensed', true],
                ['medication', 'dispensed', 'authorDatetime', false, '20170503000000', nil, 'QDM::MedicationDispensed', false],
                ['medication', 'dispensed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::MedicationDispensed', false],
                ['medication', 'dispensed', 'refills', false, '20170503000000', nil, 'QDM::MedicationDispensed', false],
                ['medication', 'dispensed', 'dosage', false, '20170503000000', nil, 'QDM::MedicationDispensed', false],
                ['medication', 'dispensed', 'supply', false, '20170503000000', nil, 'QDM::MedicationDispensed', false],
                # ['medication', 'dispensed', 'frequency', false, nil, '1234', 'QDM::MedicationDispensed', false], # roundtrip does not work with code specified in patient generator
                ['medication', 'dispensed', 'daysSupplied', false, '20170503000000', nil, 'QDM::MedicationDispensed', false],
                ['medication', 'dispensed', 'route', false, nil, '1234', 'QDM::MedicationDispensed', false],
                # ['medication', 'dispensed', 'prescriberId', false, '20170503000000', nil, 'QDM::MedicationDispensed', false], #still need the ids
                # ['medication', 'dispensed', 'dispenserId', false, '20170503000000', nil, 'QDM::MedicationDispensed', false], #still need the ids

                ['medication', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::MedicationOrder', true],
                # ['medication', 'ordered', 'relevantPeriod', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                ['medication', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                ['medication', 'ordered', 'refills', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                ['medication', 'ordered', 'dosage', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                ['medication', 'ordered', 'supply', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                # ['medication', 'ordered', 'frequency', false, nil, '1234', 'QDM::MedicationOrder', false], # roundtrip does not work with code specified in patient generator
                ['medication', 'ordered', 'daysSupplied', false, '20170503000000', nil, 'QDM::MedicationOrder', false],
                ['medication', 'ordered', 'route', false, nil, '1234', 'QDM::MedicationOrder', false],
                ['medication', 'ordered', 'setting', false, nil, '1234', 'QDM::MedicationOrder', false],
                ['medication', 'ordered', 'reason', false, nil, '1234', 'QDM::MedicationOrder', false],
                # ['medication', 'ordered', 'prescriberId', false, '20170503000000', nil, 'QDM::MedicationOrder', false],

                ['patient_characteristic', 'clinical_trial_participant', 'reason', false, nil, '1234', 'QDM::PatientCharacteristicClinicalTrialParticipant', false],
                ['patient_characteristic', 'clinical_trial_participant', 'relevantPeriod', false, '20170503000000', nil, 'QDM::PatientCharacteristicClinicalTrialParticipant', false],

                # ['patient_characteristic_expired', nil, 'expiredDatetime', false, '20170503000000', nil, 'QDM::PatientCharacteristicExpired', false], # these will need to override the code, as the code is 419099009 not 1234
                # ['patient_characteristic_expired', nil, 'cause', false, nil, '1234', 'QDM::PatientCharacteristicExpired', false] # these will need to override the code, as the code is 419099009 not 1234

                ['physical_exam', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::PhysicalExamOrder', true],
                ['physical_exam', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::PhysicalExamOrder', false],
                ['physical_exam', 'ordered', 'reason', false, nil, '1234', 'QDM::PhysicalExamOrder', false],
                ['physical_exam', 'ordered', 'anatomicalLocationSite', false, nil, '1234', 'QDM::PhysicalExamOrder', false],

                ['physical_exam', 'performed', 'negationRationale', false, nil, '1234', 'QDM::PhysicalExamPerformed', true],
                ['physical_exam', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::PhysicalExamPerformed', false],
                ['physical_exam', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::PhysicalExamPerformed', false],
                ['physical_exam', 'performed', 'reason', false, nil, '1234', 'QDM::PhysicalExamPerformed', false],
                ['physical_exam', 'performed', 'method', false, nil, '1234', 'QDM::PhysicalExamPerformed', false],
                ['physical_exam', 'performed', 'result', false, '20170503000000', nil, 'QDM::PhysicalExamPerformed', false],
                ['physical_exam', 'performed', 'anatomicalLocationSite', false, nil, '1234', 'QDM::PhysicalExamPerformed', false],
                ['physical_exam', 'performed', 'components', false, '20170503000000', nil, 'QDM::PhysicalExamPerformed', false],

                ['physical_exam', 'recommended', 'negationRationale', false, nil, '1234', 'QDM::PhysicalExamRecommended', true],
                ['physical_exam', 'recommended', 'authorDatetime', false, '20170503000000', nil, 'QDM::PhysicalExamRecommended', false],
                ['physical_exam', 'recommended', 'reason', false, nil, '1234', 'QDM::PhysicalExamRecommended', false],
                ['physical_exam', 'recommended', 'anatomicalLocationSite', false, nil, '1234', 'QDM::PhysicalExamRecommended', false],

                ['procedure', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::ProcedureOrder', true],
                ['procedure', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::ProcedureOrder', false],
                ['procedure', 'ordered', 'reason', false, nil, '1234', 'QDM::ProcedureOrder', false],
                ['procedure', 'ordered', 'anatomicalLocationSite', false, nil, '1234', 'QDM::ProcedureOrder', false],
                ['procedure', 'ordered', 'ordinality', false, nil, '1234', 'QDM::ProcedureOrder', false],

                ['procedure', 'performed', 'negationRationale', false, nil, '1234', 'QDM::ProcedurePerformed', true],
                ['procedure', 'performed', 'negationRationale', false, nil, '1234', 'QDM::ProcedurePerformed', true],
                ['procedure', 'performed', 'authorDatetime', false, '20170503000000', nil, 'QDM::ProcedurePerformed', false],
                ['procedure', 'performed', 'relevantPeriod', false, '20170503000000', nil, 'QDM::ProcedurePerformed', false],
                ['procedure', 'performed', 'reason', false, nil, '1234', 'QDM::ProcedurePerformed', false],
                ['procedure', 'performed', 'method', false, nil, '1234', 'QDM::ProcedurePerformed', false],
                ['procedure', 'performed', 'result', false, '20170503000000', nil, 'QDM::ProcedurePerformed', false],
                ['procedure', 'performed', 'status', false, nil, '1234', 'QDM::ProcedurePerformed', false],
                ['procedure', 'performed', 'anatomicalLocationSite', false, nil, '1234', 'QDM::ProcedurePerformed', false],
                ['procedure', 'performed', 'ordinality', false, nil, '1234', 'QDM::ProcedurePerformed', false],
                ['procedure', 'performed', 'incisionDatetime', false, '20170503000000', nil, 'QDM::ProcedurePerformed', false],
                ['procedure', 'performed', 'components', false, nil, '1234', 'QDM::ProcedurePerformed', false],

                ['procedure', 'recommended', 'negationRationale', false, nil, '1234', 'QDM::ProcedureRecommended', true],
                ['procedure', 'recommended', 'authorDatetime', false, '20170503000000', nil, 'QDM::ProcedureRecommended', false],
                ['procedure', 'recommended', 'reason', false, nil, '1234', 'QDM::ProcedureRecommended', false],
                ['procedure', 'recommended', 'anatomicalLocationSite', false, nil, '1234', 'QDM::ProcedureRecommended', false],
                ['procedure', 'recommended', 'ordinality', false, nil, '1234', 'QDM::ProcedureRecommended', false],

                ['provider_characteristic', nil, 'authorDatetime', false, '20170503000000', nil, 'QDM::ProviderCharacteristic', false],
                ['provider_care_experience', nil, 'authorDatetime', false, '20170503000000', nil, 'QDM::ProviderCareExperience', false],

                ['substance', 'administered', 'negationRationale', false, nil, '1234', 'QDM::SubstanceAdministered', true],
                ['substance', 'administered', 'authorDatetime', false, '20170503000000', nil, 'QDM::SubstanceAdministered', false],
                ['substance', 'administered', 'relevantPeriod', false, '20170503000000', nil, 'QDM::SubstanceAdministered', false],
                ['substance', 'administered', 'dosage', false, '20170503000000', nil, 'QDM::SubstanceAdministered', false],
                # ['substance', 'administered', 'frequency', false, '1234', nil, 'QDM::SubstanceAdministered', false], # roundtrip does not work with code specified in patient generator
                ['substance', 'administered', 'route', false, nil, '1234', 'QDM::SubstanceAdministered', false],

                ['substance', 'ordered', 'negationRationale', false, nil, '1234', 'QDM::SubstanceOrder', true],
                ['substance', 'ordered', 'authorDatetime', false, '20170503000000', nil, 'QDM::SubstanceOrder', false],
                ['substance', 'ordered', 'reason', false, nil, '1234', 'QDM::SubstanceOrder', false],
                ['substance', 'ordered', 'dosage', false, '20170503000000', nil, 'QDM::SubstanceOrder', false],
                ['substance', 'ordered', 'supply', false, '20170503000000', nil, 'QDM::SubstanceOrder', false],
                # ['substance', 'ordered', 'frequency', false, '1234', nil, 'QDM::SubstanceOrder', false],# roundtrip does not work with code specified in patient generator
                ['substance', 'ordered', 'refills', false, '20170503000000', nil, 'QDM::SubstanceOrder', false],
                ['substance', 'ordered', 'route', false, nil, '1234', 'QDM::SubstanceOrder', false],

                ['substance', 'recommended', 'negationRationale', false, nil, '1234', 'QDM::SubstanceRecommended', true],
                ['substance', 'recommended', 'authorDatetime', false, '20170503000000', nil, 'QDM::SubstanceRecommended', false],
                ['substance', 'recommended', 'reason', false, nil, '1234', 'QDM::SubstanceRecommended', false],
                ['substance', 'recommended', 'dosage', false, '20170503000000', nil, 'QDM::SubstanceRecommended', false],
                # ['substance', 'recommended', 'frequency', false, '1234', nil, 'QDM::SubstanceRecommended', false], # roundtrip does not work with code specified in patient generator
                ['substance', 'recommended', 'refills', false, '20170503000000', nil, 'QDM::SubstanceRecommended', false],
                ['substance', 'recommended', 'route', false, nil, '1234', 'QDM::SubstanceRecommended', false],

                ['symptom', nil, 'prevalencePeriod', false, '20170503000000', nil, 'QDM::Symptom', false],
                ['symptom', nil, 'severity', false, nil, '1234', 'QDM::Symptom', false]].freeze

  def test_validate_good_files
    validator = CqmValidators::Cat1R5.instance
    cda_validator = CqmValidators::CDA.instance

    TEST_ARRAY.each do |ta|
      dt = QDM::PatientGeneration.generate_loaded_datatype(ta[6], ta[7])
      setup_sdc(dt.clone, ta[2], ta[3], ta[4], ta[5])

      dt.prescriberId = QDM::Id.new(namingSystem: '1.2.3.4', value: '1234') if dt.respond_to?(:prescriberId)
      dt.dispenserId = QDM::Id.new(namingSystem: '1.2.3.4', value: '1234') if dt.respond_to?(:dispenserId)

      test_specific_qdm_patient = @qdm_patient.clone
      test_specific_qdm_patient.dataElements << dt
      @cqm_patient.qdmPatient = test_specific_qdm_patient

      patient_xml = Qrda1R5.new(@cqm_patient, Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'), @options).render

      doc = Nokogiri::XML::Document.parse(patient_xml)
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
      @validator.validate(doc)

      begin
        exported_qrda = doc
        errors = validator.validate(exported_qrda)
        cda_errors = cda_validator.validate(exported_qrda)
        errors.each do |error|
          puts "\e[31mSchema Error In #{ta[0]}_#{ta[1]}: #{error.message}\e[0m"
        end
        cda_errors.each do |error|
          puts "\e[31mSchema Error In #{ta[0]}_#{ta[1]}: #{error.message}\e[0m"
        end
      rescue StandardError => e
        puts "\e[31mException validating #{ta[0]}_#{ta[1]}: #{e.message}\e[0m"
      end

      assert @checklist_test.checked_criteria.first[:passed_qrda], "should pass with a good file for #{ta[0]} #{ta[1]} with a #{ta[2]}"
    end
  end

  def test_validate_bad_files
    TEST_ARRAY.each do |ta|
      restricted_dt = QDM::PatientGeneration.generate_loaded_datatype(ta[6])
      setup_sdc(restricted_dt, ta[2], ta[3], ta[4], ta[5])

      restricted_dt.prescriberId = QDM::Id.new(namingSystem: '1.2.3.4', value: '1234') if restricted_dt.respond_to?(:prescriberId)
      restricted_dt.dispenserId = QDM::Id.new(namingSystem: '1.2.3.4', value: '1234') if restricted_dt.respond_to?(:dispenserId)

      restricted_dt[ta[2]] = nil

      test_specific_qdm_patient = @qdm_patient.clone
      test_specific_qdm_patient.dataElements << restricted_dt
      @cqm_patient.qdmPatient = test_specific_qdm_patient

      patient_xml = Qrda1R5.new(@cqm_patient, Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'), @options).render

      doc = Nokogiri::XML::Document.parse(patient_xml)
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')

      @validator.validate(doc)
      assert_nil @checklist_test.checked_criteria.first[:passed_qrda], "should fail with a bad file for #{ta[0]} #{ta[1]} with a #{ta[2]}"
    end
  end
end
