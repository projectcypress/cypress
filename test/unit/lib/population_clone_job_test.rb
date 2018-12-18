require 'test_helper'
require 'fileutils'

class PopulationCloneJobTest < ActiveSupport::TestCase
  def setup
    @pt = FactoryBot.create(:product_test_static_result)
    @pt.save!
  end

  def test_perform_full_deck
    pcj = Cypress::PopulationCloneJob.new('test_id' => @pt.id)
    pcj.perform
    assert_equal 19, Patient.count
    assert_equal 10, Patient.where('extendedData.correlation_id': @pt.id).count
  end

  # need a measure with a subset
  # def test_perform_subset
  #   pcj = Cypress::PopulationCloneJob.new('subset_id' => 'test', 'test_id' => @pt.id)
  #   pcj.perform
  #   assert_equal 23, Record.count
  #   assert_equal 8, Record.where(test_id: @pt.id).count
  # end

  # def test_perform_two_patients
  #   # ids passed in should clone just the 2 records
  #   pcj = Cypress::PopulationCloneJob.new('patient_ids' => %w(0989db70-4d42-0135-8680-20999b0ed66f 098718e0-4d42-0135-8680-12999b0ed66f),
  #                                         'test_id' => '4f636b3f1d41c851eb000491',
  #                                         'randomization_ids' => [])
  #   pcj.perform
  #   assert_equal 17, Record.count
  #   assert_equal 2, Record.where(test_id: '4f636b3f1d41c851eb000491').count
  # end

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
    patients_with_provider = Patient.where('extendedData.correlation_id': @pt.id, 'extendedData.provider_performances': { :$exists => true })
    assert_equal 1, patients_with_provider.keep_if { |pt| pt.provider.id == prov.id }.size
  end

  # def test_assigns_generated_provider
  #   Provider.destroy_all
  #   # 0 providers to start
  #   assert_equal 0, Provider.count
  #   # ids passed in should clone just the 2 records
  #   pcj = Cypress::PopulationCloneJob.new('patient_ids' => %w(0989db70-4d42-0135-8680-20999b0ed66f 098718e0-4d42-0135-8680-12999b0ed66f),
  #                                         'test_id' => '4f636b3f1d41c851eb000491',
  #                                         'randomization_ids' => [],
  #                                         'generate_provider' => true)
  #   pcj.perform
  #   record = Record.where(test_id: '4f636b3f1d41c851eb000491').first
  #   assert_equal 17, Record.count
  #   # 2 providers were created
  #   assert_equal 2, Provider.count
  #   # provider in record matches ones of the generated providers
  #   assert Provider.find(record.provider_performances.first.provider_id)
  # end

  def test_shifts_dates_no_shift
    # Setup test data for non-date-shifting patients
    patient1_no_shift = Patient.all[0].clone
    patient2_no_shift = Patient.all[1].clone
    # Add 1 month to birthDatetime so that it is not sitting on a year boundry
    # this is so that the randomization won't cross the year boundry to make assertions consistent
    patient1_no_shift.birthDatetime += 1.month
    patient2_no_shift.birthDatetime += 1.month
    patient1_no_shift.save
    patient2_no_shift.save
    # Build and perform the date-shifting and non-date-shifting PopulationCloneJobs
    pcj1 = Cypress::PopulationCloneJob.new('patient_ids' => [patient1_no_shift.id.to_s], 'test_id' => @pt.id.to_s,
                                           'randomization_ids' => [patient2_no_shift.id.to_s])
    pcj1.perform

    # Get the patients that resulted from the cloning in the PopulationCloneJobs
    patient1_no_shift_clone  = Patient.where('extendedData.original_patient': patient1_no_shift.id).first
    patient2_randomized_no_shift_clone  = Patient.where('extendedData.original_patient': patient2_no_shift.id).first

    # assert patient1_no_shift_clone has not been shifted
    assert_equal patient1_no_shift_clone.birthDatetime, patient1_no_shift_clone.birthDatetime
    # assert patient2_randomized_no_shift_clone has not been shifted
    assert_equal Time.zone.at(patient2_randomized_no_shift_clone.birthDatetime).year, Time.zone.at(patient2_no_shift.birthDatetime).year
    # assert patient2_no_shift_clone has been randomized
    assert_not_equal Time.zone.at(patient2_randomized_no_shift_clone.birthDatetime).day, Time.zone.at(patient2_no_shift.birthDatetime).day
    # assert patient2_randomized_shift_clone randomized
    assert_not_equal Time.zone.at(patient2_randomized_no_shift_clone.birthDatetime).day, Time.zone.at(patient2_no_shift.birthDatetime).day
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
    patient1_shift.birthDatetime += 1.month
    patient2_shift.birthDatetime += 1.month
    patient1_shift.save
    patient2_shift.save
    pcj2 = Cypress::PopulationCloneJob.new('patient_ids' => [patient1_shift.id.to_s], 'test_id' => pt2.id,
                                           'randomization_ids' => [patient2_shift.id.to_s])
    pcj2.perform
    # Get the patients that resulted from the cloning in the PopulationCloneJobs
    patient1_shift_clone  = Patient.where('extendedData.original_patient': patient1_shift.id).first
    patient2_randomized_shift_clone  = Patient.where('extendedData.original_patient': patient2_shift.id).first

    # assert patient1_shift_clone has been shifted by 2 years which is the offset in the bundle associated with the product test
    assert_equal Time.zone.at(patient1_shift_clone.birthDatetime).year, Time.zone.at(patient1_shift.birthDatetime).year + 2
    # assert patient2_randomized_shift_clone has shifted by 2 years which is the offset in the bundle associated with the product test
    assert_equal Time.zone.at(patient2_randomized_shift_clone.birthDatetime).year, Time.zone.at(patient2_shift.birthDatetime).year + 2
    # assert patient2_randomized_shift_clone randomized
    assert_not_equal Time.zone.at(patient2_randomized_shift_clone.birthDatetime).day, Time.zone.at(patient2_shift.birthDatetime).day

  end

  # def test_perform_two_patients_randomized_ids
  #   # ids passed in should clone just the 2 records
  #   pcj = Cypress::PopulationCloneJob.new('patient_ids' => %w(0989db70-4d42-0135-8680-20999b0ed66f 098718e0-4d42-0135-8680-12999b0ed66f),
  #                                         'test_id' => '4f636b3f1d41c851eb000491',
  #                                         'randomization_ids' => %w(0989db70-4d42-0135-8680-20999b0ed66f 098718e0-4d42-0135-8680-12999b0ed66f
  #                                                                   0989db70-4d42-0135-8680-20999b0ed66f 098718e0-4d42-0135-8680-12999b0ed66f
  #                                                                   0989db70-4d42-0135-8680-20999b0ed66f 098718e0-4d42-0135-8680-12999b0ed66f))
  #   pcj.perform
  #   r_count = Record.count
  #   assert r_count >= 18 && r_count <= 22,
  #          'Should be 18 or 22 records depending on how many records were chosen for randomization'
  #   count = Record.where(test_id: '4f636b3f1d41c851eb000491').count
  #   assert count >= 3 && count <= 7,
  #          "should be 3 or 7 records depending on how many records were chosen for randomization was #{count} "
  # end

  # def test_perform_two_patients_randomized_names
  #   # Clone two and ensure they have random (new) names
  #   pcj = Cypress::PopulationCloneJob.new('patient_ids' => %w(0989db70-4d42-0135-8680-20999b0ed66f 098718e0-4d42-0135-8680-12999b0ed66f),
  #                                         'test_id' => '4f636b3f1d41c851eb000491',
  #                                         'randomize_demographics' => true)
  #   pcj.perform
  #   new_records = Record.where(test_id: '4f636b3f1d41c851eb000491')
  #   assert_equal 2, new_records.count
  #   new_records.each do |record|
  #     assert_not_equal 'Selena Lotherberg', "#{record.first} #{record.last}"
  #     assert_not_equal 'Rosa Vasquez', "#{record.first} #{record.last}"
  #   end
  # end

  def test_perform_reconnect_reference
    # Add an element with a reference to the first patient in the product test
    patient_with_ref = @pt.bundle.patients.first
    comm_with_ref = QDM::CommunicationPerformed.new(dataElementCodes: [QDM::Code.new('336', '2.16.840.1.113883.6.96')])
    comm_with_ref.relatedTo << patient_with_ref.dataElements[0].id
    patient_with_ref.dataElements << comm_with_ref
    patient_with_ref.save
    pcj = Cypress::PopulationCloneJob.new('subset_id' => 'all',
                                          'test_id' => @pt.id,
                                          'patient_ids' => [patient_with_ref.id],
                                          'randomize_demographics' => true)
    pcj.perform
    new_record_with_ref = Patient.where('extendedData.correlation_id': @pt.id, 'extendedData.original_patient': patient_with_ref.id).first
    new_ref = new_record_with_ref.communications.first.relatedTo.first.value
    original_ref = patient_with_ref.communications.first.relatedTo.first.value
    assert_not_equal new_ref, original_ref
  end

  def test_perform_randomized_races
    # Clone and ensure they have random races
    pcj = Cypress::PopulationCloneJob.new('subset_id' => 'all',
                                          'test_id' => @pt.id,
                                          'randomize_demographics' => true)
    pcj.perform
    new_records = Patient.where('extendedData.correlation_id': @pt.id)
    assert_equal 10, new_records.count
    assert_races_are_random
  end

  def assert_races_are_random
    found_random = false
    old_record_races = {}
    Patient.where('extendedData.correlation_id': nil).each do |record|
      old_record_races["#{record.givenNames[0]} #{record.familyName}"] = record.race
    end
    Patient.where('extendedData.correlation_id': @pt.id).each do |record|
      found_random = true unless old_record_races["#{record.givenNames[0]} #{record.familyName}"] == record.race
    end
    assert found_random, 'Did not find any evidence that race was randomized.'
  end

  # def test_perform_randomized_ethnicities
  #   # Clone and ensure they have random ethnicities
  #   pcj = Cypress::PopulationCloneJob.new('subset_id' => 'all',
  #                                         'test_id' => @pt.id,
  #                                         'randomize_demographics' => true)
  #   pcj.perform
  #   new_records = Record.where(test_id: @pt.id)
  #   assert_equal 8, new_records.count
  #   assert_ethnicities_are_random
  # end

  # def assert_ethnicities_are_random
  #   found_random = false
  #   old_record_ethnicities = {}
  #   Record.where(test_id: nil).each do |record|
  #     old_record_ethnicities["#{record.first} #{record.last}"] = record.ethnicity['code']
  #   end
  #   Record.where(test_id: @pt.id).each do |record|
  #     found_random = true unless old_record_ethnicities["#{record.first} #{record.last}"] == record.ethnicity['code']
  #   end
  #   assert found_random, 'Did not find any evidence that ethnicity was randomized.  Since there are only two ' \
  #     'possible ethnicities there is some mathematical chance that this might happen, but it is slim (4/1000)!'
  # end

  # def test_perform_randomized_addresses
  #   # Clone and ensure they have random addresses
  #   pcj = Cypress::PopulationCloneJob.new('subset_id' => 'all',
  #                                         'test_id' => @pt.id,
  #                                         'randomize_demographics' => true)
  #   pcj.perform
  #   new_records = Record.where(test_id: @pt.id)
  #   assert_equal 8, new_records.count
  #   new_records.each do |record|
  #     assert_equal 1, record.addresses.count
  #     assert_valid_address(record.addresses[0])
  #   end
  # end

  # def assert_valid_address(address)
  #   assert_equal 'HP', address.use
  #   assert_not_nil address.street
  #   assert_not_nil address.city
  #   assert_not_nil address.state
  #   assert_not_nil address.zip
  #   assert_equal 'US', address.country
  # end

  # def test_perform_randomized_insurance_provider
  #   # Clone and ensure they have random insurance provider data
  #   pcj = Cypress::PopulationCloneJob.new('subset_id' => 'all',
  #                                         'test_id' => @pt.id,
  #                                         'randomize_demographics' => true)
  #   pcj.perform
  #   new_records = Record.where(test_id: @pt.id)
  #   assert_equal 8, new_records.count
  #   new_records.each do |record|
  #     assert_equal 1, record.insurance_providers.count
  #     assert_payers_are_random
  #   end
  # end

  # def assert_payers_are_random
  #   found_random = false
  #   old_record_payers = {}
  #   Record.where(test_id: nil).each do |record|
  #     next if record.insurance_providers.empty?
  #     old_record_payers["#{record.first} #{record.last}"] = record.insurance_providers[0].type
  #   end
  #   Record.where(test_id: @pt.id).each do |record|
  #     found_random = true unless old_record_payers["#{record.first} #{record.last}"] == record.insurance_providers[0].type
  #   end
  #   assert found_random == true, 'Did not find any evidence that payer was randomized.  Since there are only three ' \
  #     'possible payers there is some mathematical chance that this might happen, but it is slim (1/10,000)!'
  # end

  # def test_clone_and_save_record_with_provider
  #   test = ProductTest.find(@pt.id)
  #   record = test.bundle.records.where(test_id: nil).sample
  #   provider = Provider.generate_provider(measure_type: test.measures.first.type)

  #   pcj = Cypress::PopulationCloneJob.new({ 'test_id' => test.id }.stringify_keys!)
  #   prng = Random.new(test.rand_seed.to_i)
  #   pcj.clone_and_save_record(record, prng, provider)
  #   cloned_record = Record.find_by(test_id: test.id)

  #   cloned_record.provider_performances.each do |provider_performance|
  #     assert_equal provider.id, provider_performance.provider_id
  #   end
  # end

  # def test_perform_on_measure_test_creates_patients_with_same_provider
  #   product = Product.find('4f57a88a1d41c851eb000004')
  #   test = product.product_tests.build({ name: "my measure test #{rand}", measure_ids: ['8A4D92B2-397A-48D2-0139-C648B33D5582'] }, MeasureTest)
  #   test.save!

  #   # make one record (pre-cloned record) have a provider performance. PopulationCloneJob should take care of this
  #   provider = Provider.find(BSON::ObjectId('53b2c4414d4d32139c730000'))
  #   Record.where(test_id: nil).sample.provider_performances << ProviderPerformance.new(provider: provider)

  #   # add provider to test before clone job
  #   test.provider = provider
  #   test.save!

  #   # create cloned record for measure test
  #   records = clone_records(test)

  #   # population clone job should set provider for measure test
  #   assert_equal provider, ProductTest.find(test.id).provider

  #   assert_equal 8, records.count
  #   assert records.all { |record| record.provider_performances.any? }

  #   # assert provider for each record on the measure test are the same
  #   first_provider = records.first.provider_performances.first.provider
  #   records.each do |record|
  #     assert_equal first_provider, record.provider_performances.first.provider
  #   end
  # end

  def clone_records(product_test, options = {})
    options['test_id'] = product_test.id unless options['test_id']
    options['subset_id'] = 'all'
    options['randomize_demographics'] = true
    pcj = Cypress::PopulationCloneJob.new(options.stringify_keys!)
    pcj.perform
    Record.where(test_id: product_test.id)
  end
end
