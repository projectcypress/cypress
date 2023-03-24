# frozen_string_literal: true

require 'test_helper'

class QrdaPostProcessorTest < ActiveSupport::TestCase
  def setup
    @bundle = FactoryBot.create(:executable_bundle)
    @patient = BundlePatient.new(givenNames: ['Patient'], familyName: 'Test', bundleId: @bundle.id)
  end

  def test_keep_matched_data_type_code_combinations
    @bundle.categorized_codes = { 'substance' => [{ 'code' => '1', 'system' => '2.16.840.1.113883' }],
                                  'medication' => [{ 'code' => '2', 'system' => '2.16.840.1.113883' }] }
    substance_codes = [{ code: '1', system: '2.16.840.1.113883' }]
    medication_codes = [{ code: '2', system: '2.16.840.1.113883' }]
    @patient.qdmPatient.dataElements.push QDM::SubstanceAdministered.new(dataElementCodes: substance_codes)
    @patient.qdmPatient.dataElements.push QDM::MedicationAdministered.new(dataElementCodes: medication_codes)
    assert_equal 1, @patient.qdmPatient.substances.size
    assert_equal 1, @patient.qdmPatient.medications.size
    Cypress::QrdaPostProcessor.remove_unmatched_data_type_code_combinations(@patient, @bundle)
    # Since both medication and substance code match the codes available for their QDM type, no data elements are removed
    assert_equal 1, @patient.qdmPatient.substances.size
    assert_equal 1, @patient.qdmPatient.medications.size
  end

  def test_remove_unmatched_data_type_code_combinations
    @bundle.categorized_codes = { 'substance' => [{ 'code' => '1', 'system' => '2.16.840.1.113883' }],
                                  'medication' => [{ 'code' => '2', 'system' => '2.16.840.1.113883' }] }
    substance_codes = [{ code: '1', system: '2.16.840.1.113883' }]
    medication_codes = [{ code: '2', system: '2.16.840.1.113883' }]
    @patient.qdmPatient.dataElements.push QDM::SubstanceAdministered.new(dataElementCodes: substance_codes)
    @patient.qdmPatient.dataElements.push QDM::MedicationAdministered.new(dataElementCodes: substance_codes)
    @patient.qdmPatient.dataElements.push QDM::SubstanceAdministered.new(dataElementCodes: medication_codes)
    @patient.qdmPatient.dataElements.push QDM::MedicationAdministered.new(dataElementCodes: medication_codes)
    assert_equal 2, @patient.qdmPatient.substances.size
    assert_equal 2, @patient.qdmPatient.medications.size
    Cypress::QrdaPostProcessor.remove_unmatched_data_type_code_combinations(@patient, @bundle)
    # The medication element using the substance_codes and the substance elment using the medication code will be removed
    assert_equal 1, @patient.qdmPatient.substances.size
    assert_equal '1', @patient.qdmPatient.substances.first.dataElementCodes.first.code
    assert_equal 1, @patient.qdmPatient.medications.size
    assert_equal '2', @patient.qdmPatient.medications.first.dataElementCodes.first.code
  end

  def test_keep_unchecked_data_type_code_combinations
    # no QDM types will be checked
    @bundle.categorized_codes = {}
    substance_codes = [{ code: '1', system: '2.16.840.1.113883' }]
    medication_codes = [{ code: '2', system: '2.16.840.1.113883' }]
    @patient.qdmPatient.dataElements.push QDM::SubstanceAdministered.new(dataElementCodes: substance_codes)
    @patient.qdmPatient.dataElements.push QDM::MedicationAdministered.new(dataElementCodes: substance_codes)
    @patient.qdmPatient.dataElements.push QDM::SubstanceAdministered.new(dataElementCodes: medication_codes)
    @patient.qdmPatient.dataElements.push QDM::MedicationAdministered.new(dataElementCodes: medication_codes)
    assert_equal 2, @patient.qdmPatient.substances.size
    assert_equal 2, @patient.qdmPatient.medications.size
    Cypress::QrdaPostProcessor.remove_unmatched_data_type_code_combinations(@patient, @bundle)
    # since categorized_codes is empty, no elements will be removed
    assert_equal 2, @patient.qdmPatient.substances.size
    assert_equal 2, @patient.qdmPatient.medications.size
  end
end
