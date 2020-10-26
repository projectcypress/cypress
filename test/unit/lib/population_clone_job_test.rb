require 'test_helper'
require 'fileutils'

class PopulationCloneJobTest < ActiveSupport::TestCase
  def setup
    @pt = FactoryBot.create(:product_test_static_result)
    @pt.save!
  end

  def test_randomization_of_names
    original_male_first = NAMES_RANDOM['first']['M']
    original_female_first = NAMES_RANDOM['first']['F']
    original_last = NAMES_RANDOM['first']['F']
    # 6 unique male first names
    NAMES_RANDOM['first']['M'] = %w[Joe Jack John James Jethro Jackson Joseph]
    # 6 uniqiue Female first names
    NAMES_RANDOM['first']['F'] = %w[Jill Julie Jackie Jessica Joy Jenna Jennifer]
    # 6 uniqiue last names
    NAMES_RANDOM['last'] = %w[Smith Doe]
    pcj = Cypress::PopulationCloneJob.new({})
    patient = @pt.patients.first
    @pt.patients.destroy
    options = { 'test_id' => @pt.id,
                'randomize_demographics' => true }
    pcj.instance_variable_set(:@test, @pt)
    pcj.instance_variable_set(:@options, options)
    # There are 7 unique first names, and 2 unique last names.
    # There are only 14 possible unique combinations.
    # We test with 13 to avoid having to randomly hit the last name combination with a 1/14 chance on each name generation.
    13.times do
      pcj.send(:clone_and_save_patient, patient, Random.new(@pt.rand_seed.to_i))
    end
    @pt.save
    @pt.reload
    # Assert that 13 patients have been made
    assert_equal 13, @pt.patients.size
    # All 13 patients have unqiue names
    assert_equal 13, @pt.patients.map { |p| "#{p.givenNames[0]}_#{p.familyName}" }.uniq.size
    NAMES_RANDOM['first']['M'] = original_male_first
    NAMES_RANDOM['first']['F'] = original_female_first
    NAMES_RANDOM['last'] = original_last
  end

  def test_perform_full_deck
    pcj = Cypress::PopulationCloneJob.new('test_id' => @pt.id)
    pcj.perform
    assert_equal 19, Patient.count
    assert_equal 10, Patient.where(correlation_id: @pt.id).count
  end

  def test_preferred_code_procedure_without_vendor_perference
    pcj = Cypress::PopulationCloneJob.new('test_id' => @pt.id)
    pcj.find_patients_to_clone
    original_patient = @pt.patients.first
    original_procedure_codes = original_patient.qdmPatient.procedures.first.dataElementCodes
    # There are two codes in the original patients procedure
    assert_equal 2, original_procedure_codes.size
    cloned_patient = original_patient.clone
    pcj.restrict_entry_codes(cloned_patient)
    cloned_procedure_codes = cloned_patient.qdmPatient.procedures.first.dataElementCodes
    # There should only be one codes in the cloned patients procedure
    assert_equal 1, cloned_procedure_codes.size
  end

  def test_preferred_code_procedure_with_vendor_perference_snomedct
    assert_code_preferences(%w[2.16.840.1.113883.6.96])
  end

  def test_preferred_code_procedure_with_vendor_perference_cpt
    assert_code_preferences(%w[2.16.840.1.113883.6.12])
  end

  def test_preferred_code_procedure_with_vendor_perference_not_found
    pcj = Cypress::PopulationCloneJob.new('test_id' => @pt.id)
    pcj.find_patients_to_clone
    vendor = @pt.product.vendor
    vendor.preferred_code_systems['procedure'] = ['1.2.3']
    vendor.save
    original_patient = @pt.patients.first
    cloned_patient = original_patient.clone
    pcj.restrict_entry_codes(cloned_patient)
    cloned_procedure_codes = cloned_patient.qdmPatient.procedures.first.dataElementCodes
    # There should only be one codes in the cloned patients procedure
    assert_equal 1, cloned_procedure_codes.size
    # The cloned code should not be from the FAKECS code system
    assert_not_equal '1.2.3', cloned_procedure_codes[0].system
  end

  def test_preferred_code_procedure_with_ordered_vendor_perference_snomedct_first
    assert_code_preferences(%w[2.16.840.1.113883.6.96 2.16.840.1.113883.6.12])
  end

  def test_preferred_code_procedure_with_ordered_vendor_perference_cpt_first
    assert_code_preferences(%w[2.16.840.1.113883.6.12 2.16.840.1.113883.6.96])
  end

  def assert_code_preferences(preferred_code_systems)
    pcj = Cypress::PopulationCloneJob.new('test_id' => @pt.id)
    pcj.find_patients_to_clone
    vendor = @pt.product.vendor
    vendor.preferred_code_systems['procedure'] = preferred_code_systems
    vendor.save
    original_patient = @pt.patients.first
    cloned_patient = original_patient.clone
    pcj.restrict_entry_codes(cloned_patient)
    cloned_procedure_codes = cloned_patient.qdmPatient.procedures.first.dataElementCodes
    # There should still be two codes in the original patients procedure
    assert_equal 2, original_patient.qdmPatient.procedures.first.dataElementCodes.size
    # There should only be one codes in the cloned patients procedure
    assert_equal 1, cloned_procedure_codes.size
    # The cloned code should be from the SNOMEDCT code system
    assert_equal preferred_code_systems[0], cloned_procedure_codes[0].system
  end

  def test_assigns_default_provider
    # ids passed in should clone just the 1 record
    sample_patient = @pt.bundle.patients.sample
    @pt.provider = Provider.default_provider
    @pt.save!
    pcj = Cypress::PopulationCloneJob.new('patient_ids' => [sample_patient.id],
                                          'test_id' => @pt.id,
                                          'randomization_ids' => [])
    pcj.perform
    prov = Provider.where(default: true).first
    assert_equal 11, Patient.count
    patients_with_provider = Patient.where(correlation_id: @pt.id, provider_ids: { :$exists => true })
    assert_equal 1, patients_with_provider.keep_if { |pt| pt.providers.map(&:id).include? prov.id }.size
  end

  def test_shifts_dates_no_shift
    # Setup test data for non-date-shifting patients
    patient1_no_shift = Patient.all[0].clone
    patient2_no_shift = Patient.all[1].clone
    # Add 1 month to birthDatetime so that it is not sitting on a year boundry
    # this is so that the randomization won't cross the year boundry to make assertions consistent
    patient1_no_shift.qdmPatient.birthDatetime += 1.month
    patient2_no_shift.qdmPatient.birthDatetime += 1.month
    patient1_no_shift.save
    patient2_no_shift.save
    # Build and perform the date-shifting and non-date-shifting PopulationCloneJobs
    pcj1 = Cypress::PopulationCloneJob.new('patient_ids' => [patient1_no_shift.id.to_s], 'test_id' => @pt.id.to_s,
                                           'randomization_ids' => [patient2_no_shift.id.to_s])
    patients = pcj1.perform

    # Get the patients that resulted from the cloning in the PopulationCloneJobs
    patient1_no_shift_clone = patients.select { |patient| patient.original_patient_id == patient1_no_shift.id }.first
    patient2_randomized_no_shift_clone = patients.select { |patient| patient.original_patient_id == patient2_no_shift.id }.first

    # assert patient1_no_shift_clone has not been shifted
    assert_equal patient1_no_shift_clone.qdmPatient.birthDatetime, patient1_no_shift_clone.qdmPatient.birthDatetime
    # assert patient2_randomized_no_shift_clone has not been shifted
    assert_equal Time.zone.at(patient2_randomized_no_shift_clone.qdmPatient.birthDatetime).year, Time.zone.at(patient2_no_shift.qdmPatient.birthDatetime).year
    # assert patient2_no_shift_clone has been randomized
    assert_not_equal Time.zone.at(patient2_randomized_no_shift_clone.qdmPatient.birthDatetime).day, Time.zone.at(patient2_no_shift.qdmPatient.birthDatetime).day
    # assert patient2_randomized_shift_clone randomized
    assert_not_equal Time.zone.at(patient2_randomized_no_shift_clone.qdmPatient.birthDatetime).day, Time.zone.at(patient2_no_shift.qdmPatient.birthDatetime).day
  end

  def test_shifts_dates_with_shift
    # Setup test data for date-shifting patients
    pt2 = @pt.clone
    pt2.product.shift_patients = true
    pt2.save!
    patient1_shift = Patient.all[0].clone
    patient2_shift = Patient.all[1].clone
    # Add 1 month to birthDatetime so that it is not sitting on a year boundry
    # this is so that the randomization won't cross the year boundry to make assertions consistent
    patient1_shift.qdmPatient.birthDatetime += 1.month
    patient2_shift.qdmPatient.birthDatetime += 1.month
    patient1_shift.save
    patient2_shift.save
    pcj2 = Cypress::PopulationCloneJob.new('patient_ids' => [patient1_shift.id.to_s], 'test_id' => pt2.id,
                                           'randomization_ids' => [patient2_shift.id.to_s])
    patients = pcj2.perform
    # Get the patients that resulted from the cloning in the PopulationCloneJobs
    patient1_shift_clone = patients.select { |patient| patient.original_patient_id == patient1_shift.id }.first
    patient2_randomized_shift_clone = patients.select { |patient| patient.original_patient_id == patient2_shift.id }.first

    # assert patient1_shift_clone has been shifted by 2 years which is the offset in the bundle associated with the product test
    assert_equal Time.zone.at(patient1_shift_clone.qdmPatient.birthDatetime).year, Time.zone.at(patient1_shift.qdmPatient.birthDatetime).year + 2
    # assert patient2_randomized_shift_clone has shifted by 2 years which is the offset in the bundle associated with the product test
    assert_equal Time.zone.at(patient2_randomized_shift_clone.qdmPatient.birthDatetime).year, Time.zone.at(patient2_shift.qdmPatient.birthDatetime).year + 2
    # assert patient2_randomized_shift_clone randomized
    assert_not_equal Time.zone.at(patient2_randomized_shift_clone.qdmPatient.birthDatetime).day, Time.zone.at(patient2_shift.qdmPatient.birthDatetime).day
  end

  def test_perform_reconnect_reference
    # Add an element with a reference to the first patient in the product test
    patient_with_ref = @pt.bundle.patients.first
    comm_with_ref = QDM::CommunicationPerformed.new(dataElementCodes: [QDM::Code.new('336', '2.16.840.1.113883.6.96')])
    comm_with_ref.relatedTo = [patient_with_ref.qdmPatient.dataElements[0].id]
    patient_with_ref.qdmPatient.dataElements << comm_with_ref
    patient_with_ref.save
    pcj = Cypress::PopulationCloneJob.new('subset_id' => 'all',
                                          'test_id' => @pt.id,
                                          'patient_ids' => [patient_with_ref.id],
                                          'randomize_demographics' => true)
    pcj.perform
    new_record_with_ref = Patient.where(correlation_id: @pt.id, original_patient_id: patient_with_ref.id).first
    new_ref = new_record_with_ref.qdmPatient.communications.first.relatedTo.first
    original_ref = patient_with_ref.qdmPatient.communications.first.relatedTo.first
    assert_not_equal new_ref, original_ref
  end

  def test_perform_randomized_races
    # Clone and ensure they have random races
    pcj = Cypress::PopulationCloneJob.new('subset_id' => 'all',
                                          'test_id' => @pt.id,
                                          'randomize_demographics' => true)
    pcj.perform
    new_records = Patient.where(correlation_id: @pt.id)
    assert_equal 10, new_records.count
    assert_races_are_random
  end

  def test_perform_replace_other_race
    # Clone and ensure that "Other" is always replaced with the same code '2106-3'
    pcj = Cypress::PopulationCloneJob.new({})
    options = { 'test_id' => @pt.id,
                'randomize_demographics' => false }
    pcj.instance_variable_set(:@test, @pt)
    pcj.instance_variable_set(:@options, options)
    prng = Random.new(@pt.rand_seed.to_i)
    patient = Patient.first
    # Replace original race code with the code for 'Other'
    patient.qdmPatient.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code'] = '2131-1'
    pcj.send(:clone_and_save_patient, patient, prng, Provider.first)
    cloned_patient = Patient.where(original_patient_id: patient.id).first
    # Assert that the new race is consistent '2106-3'
    assert_equal '2106-3', cloned_patient.race
  end

  def assert_races_are_random
    found_random = false
    old_record_races = {}
    Patient.where(correlation_id: nil).each do |record|
      old_record_races["#{record.givenNames[0]} #{record.familyName}"] = record.race
    end
    Patient.where(correlation_id: @pt.id).each do |record|
      found_random = true unless old_record_races["#{record.givenNames[0]} #{record.familyName}"] == record.race
    end
    assert found_random, 'Did not find any evidence that race was randomized.'
  end

  def test_first_data_element_code
    negated_vs_code = { 'code' => '2.16.840.1.113883.3.117.1.7.1.230', 'system' => '1.2.3.4.5.6.7.8.9.10' }
    standard_code1 = { 'code' => '1', 'system' => '2.16.840.1.113883.6.96' }
    standard_code2 = { 'code' => '2', 'system' => '2.16.840.1.113883.6.96' }
    pcj = Cypress::PopulationCloneJob.new({})

    data_element_codes = [negated_vs_code, standard_code1]
    first_code = pcj.first_data_element_code(data_element_codes)
    assert_equal first_code, standard_code1, "First code should be code 1"

    data_element_codes = [standard_code1, standard_code2]
    first_code = pcj.first_data_element_code(data_element_codes)
    assert_equal first_code, standard_code1, "First code should be code 1"
  end

  def clone_records(product_test, options = {})
    options['test_id'] = product_test.id unless options['test_id']
    options['subset_id'] = 'all'
    options['randomize_demographics'] = true
    pcj = Cypress::PopulationCloneJob.new(options.stringify_keys!)
    pcj.perform
    Record.where(test_id: product_test.id)
  end
end
