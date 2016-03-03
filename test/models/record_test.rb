require 'test_helper'

class RecordTest < ActiveSupport::TestCase
  def setup
    collection_fixtures('bundles', 'records', 'patient_cache')
    @bundle = HealthDataStandards::CQM::Bundle.create(version: '1', name: 'test-bundle')
  end

  def test_record_knows_bundle
    record = Record.new(bundle_id: @bundle.id)
    record.save
    assert_equal @bundle, record.bundle, 'A record should know what bundle it is assocaitated with if any'
    record = Record.new
    record.save
    assert_equal nil, record.bundle, 'A record not associated with a bundle should return nil'
  end

  def test_record_should_be_able_to_find_original
    r1 = Record.new(medical_record_number: '1a', bundle_id: @bundle.id)
    r1.save
    r2 = Record.new(medical_record_number: '1b', original_medical_record_number: '1a', bundle_id: @bundle.id)
    r2.save
    assert_equal r1, r2.original_record, 'Record should be able to find record it was cloned from'
  end

  def test_record_should_be_able_to_find_calculation_results
    r = Record.find('51703a883054cf84390000d4')
    assert_equal 2, r.calculation_results.count, 'record should have 2 calculated results'
  end
end
