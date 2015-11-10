require 'test_helper'
require 'fileutils'

# rubocop:disable Metrics/ClassLength

class PopulationCloneJobTest < ActiveSupport::TestCase
  def setup
    collection_fixtures('records', 'product_tests', 'bundles', 'measures')
  end

  def test_perform_full_deck
    pcj = Cypress::PopulationCloneJob.new('subset_id' => 'all', 'test_id' => '4f58f8de1d41c851eb000478')
    pcj.perform
    assert_equal 23, Record.count
    assert_equal 9, Record.where(test_id: '4f58f8de1d41c851eb000478').count
  end

  def test_perform_subset
    pcj = Cypress::PopulationCloneJob.new('subset_id' => 'test', 'test_id' => '4f5a606b1d41c851eb000484')
    pcj.perform
    assert_equal 23, Record.count
    assert_equal 8, Record.where(test_id: '4f5a606b1d41c851eb000484').count
  end

  def test_perform_two_patients
    # ids passed in should clone just the 2 records
    pcj = Cypress::PopulationCloneJob.new('patient_ids' => %w(19 20),
                                          'test_id' => '4f636b3f1d41c851eb000491',
                                          'randomization_ids' => [])
    pcj.perform
    assert_equal 17, Record.count
    assert_equal 2, Record.where(test_id: '4f636b3f1d41c851eb000491').count
  end

  def test_perform_two_patients_randomized_ids
    # ids passed in should clone just the 2 records
    pcj = Cypress::PopulationCloneJob.new('patient_ids' => %w(19 20),
                                          'test_id' => '4f636b3f1d41c851eb000491',
                                          'randomization_ids' => %w(19 20 19 20 19 20))
    pcj.perform
    r_count = Record.count
    assert r_count >= 18 && r_count <= 22,
           'Should be 18 or 22 records depending on how many records were chosen for randomization'
    count = Record.where(test_id: '4f636b3f1d41c851eb000491').count
    assert count >= 3 && count <= 7,
           "should be 3 or 7 records depending on how many records were chosen for randomization was #{count} "
  end

  def test_perform_two_patients_randomized_names
    # Clone two and ensure they have random (new) names
    pcj = Cypress::PopulationCloneJob.new('patient_ids' => %w(19 20),
                                          'test_id' => '4f636b3f1d41c851eb000491',
                                          'randomize_demographics' => true)
    pcj.perform
    new_records = Record.where(test_id: '4f636b3f1d41c851eb000491')
    assert_equal 2, new_records.count
    new_records.each do |record|
      assert_not_equal 'Selena Lotherberg', "#{record.first} #{record.last}"
      assert_not_equal 'Rosa Vasquez', "#{record.first} #{record.last}"
    end
  end

  def test_perform_randomized_races
    # Clone and ensure they have random races
    pcj = Cypress::PopulationCloneJob.new('subset_id' => 'all',
                                          'test_id' => '4f5a606b1d41c851eb000484',
                                          'randomize_demographics' => true)
    pcj.perform
    new_records = Record.where(test_id: '4f5a606b1d41c851eb000484')
    assert_equal 8, new_records.count
    assert_races_are_random
  end

  def assert_races_are_random
    found_random = false
    old_record_races = {}
    Record.where(test_id: nil).each do |record|
      old_record_races["#{record.first} #{record.last}"] = record.race['code']
    end
    Record.where(test_id: '4f5a606b1d41c851eb000484').each do |record|
      found_random = true unless old_record_races["#{record.first} #{record.last}"] == record.race['code']
    end
    assert found_random == true, 'Did not find any evidence that race was randomized.'
  end

  def test_perform_randomized_ethnicities
    # Clone and ensure they have random ethnicities
    pcj = Cypress::PopulationCloneJob.new('subset_id' => 'all',
                                          'test_id' => '4f5a606b1d41c851eb000484',
                                          'randomize_demographics' => true)
    pcj.perform
    new_records = Record.where(test_id: '4f5a606b1d41c851eb000484')
    assert_equal 8, new_records.count
    assert_ethnicities_are_random
  end

  def assert_ethnicities_are_random
    found_random = false
    old_record_ethnicities = {}
    Record.where(test_id: nil).each do |record|
      old_record_ethnicities["#{record.first} #{record.last}"] = record.ethnicity['code']
    end
    Record.where(test_id: '4f5a606b1d41c851eb000484').each do |record|
      found_random = true unless old_record_ethnicities["#{record.first} #{record.last}"] == record.ethnicity['code']
    end
    assert found_random == true, 'Did not find any evidence that ethnicity was randomized.  Since there are only two ' \
      'possible ethnicities there is some mathematical chance that this might happen, but it is slim (4/1000)!'
  end

  def test_perform_randomized_addresses
    # Clone and ensure they have random addresses
    pcj = Cypress::PopulationCloneJob.new('subset_id' => 'all',
                                          'test_id' => '4f5a606b1d41c851eb000484',
                                          'randomize_demographics' => true)
    pcj.perform
    new_records = Record.where(test_id: '4f5a606b1d41c851eb000484')
    assert_equal 8, new_records.count
    new_records.each do |record|
      assert_equal 1, record.addresses.count
      assert_valid_address(record.addresses[0])
    end
  end

  def assert_valid_address(address)
    assert_equal 'HP', address.use
    assert_not_nil address.street
    assert_not_nil address.city
    assert_not_nil address.state
    assert_not_nil address.zip
    assert_equal 'US', address.country
  end

  def test_perform_randomized_insurance_provider
    # Clone and ensure they have random insurance provider data
    pcj = Cypress::PopulationCloneJob.new('subset_id' => 'all',
                                          'test_id' => '4f5a606b1d41c851eb000484',
                                          'randomize_demographics' => true)
    pcj.perform
    new_records = Record.where(test_id: '4f5a606b1d41c851eb000484')
    assert_equal 8, new_records.count
    new_records.each do |record|
      assert_equal 1, record.insurance_providers.count
      assert_payers_are_random
    end
  end

  def assert_payers_are_random
    found_random = false
    old_record_payers = {}
    Record.where(test_id: nil).each do |record|
      next if record.insurance_providers.empty?
      old_record_payers["#{record.first} #{record.last}"] = record.insurance_providers[0].type
    end
    Record.where(test_id: '4f5a606b1d41c851eb000484').each do |record|
      found_random = true unless old_record_payers["#{record.first} #{record.last}"] == record.insurance_providers[0].type
    end
    assert found_random == true, 'Did not find any evidence that payer was randomized.  Since there are only three ' \
      'possible payers there is some mathematical chance that this might happen, but it is slim (1/10,000)!'
  end
end

# rubocop:enable Metrics/ClassLength
