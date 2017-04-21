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
    assert_nil record.bundle, 'A record not associated with a bundle should return nil'
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

  def record_demographics_equal?(r1, r2)
    r1.first == r2.first && r1.last == r2.last && r1.gender == r2.gender &&
      r1.birthdate == r2.birthdate && r1.race.code == r2.race.code && r1.ethnicity.code == r2.ethnicity.code
  end

  def test_record_duplicate_randomization
    random = Random.new_seed
    prng1 = Random.new(random)
    prng2 = Random.new(random)

    r1 = Record.new(
      first: 'Robert', last: 'Johnson', gender: 'M', birthdate: '477542400',
      race: Cypress::AppConfig['randomization']['races'].sample(random: prng1),
      ethnicity: Cypress::AppConfig['randomization']['ethnicities'].sample(random: prng1))

    r2 = Record.new(
      first: 'Robert', last: 'Johnson', gender: 'M', birthdate: '477542400',
      race: Cypress::AppConfig['randomization']['races'].sample(random: prng2),
      ethnicity: Cypress::AppConfig['randomization']['ethnicities'].sample(random: prng2))

    assert(record_demographics_equal?(r1, r2), 'The two records should be equal')
    r1copy = r1.duplicate_randomization(random: prng1)
    r2copy = r2.duplicate_randomization(random: prng2)
    assert(record_demographics_equal?(r1copy, r2copy), 'The two records should be equal')
    assert(!record_demographics_equal?(r1, r1copy), 'The two records should not be equal')
  end
end
