require 'test_helper'
require 'fileutils'

class PopulationCloneJobTest < ActiveSupport::TestCase
  setup do
    collection_fixtures('records', '_id', 'test_id', 'bundle_id')
    collection_fixtures('product_tests', '_id', 'bundle_id')
    collection_fixtures('bundles', '_id')
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
end
