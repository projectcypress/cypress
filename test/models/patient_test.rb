# frozen_string_literal: false

require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  def setup
    @bundle = FactoryBot.create(:static_bundle)
  end

  def test_record_knows_bundle
    patient = BundlePatient.new(bundleId: @bundle.id)
    patient.save
    assert_equal @bundle, patient.bundle, 'A record should know what bundle it is associated with if any'
  end

  def test_record_should_be_able_to_find_original
    r1 = BundlePatient.new(medical_record_number: '1a', bundleId: @bundle.id)
    r1.save
    r2 = ProductTestPatient.new(medical_record_number: '1a', original_patient_id: r1.id, bundleId: @bundle.id)
    r2.save
    assert_equal r1.id, r2.original_patient_id, 'Record should be able to find record it was cloned from'
  end

  def test_record_should_be_able_to_find_calculation_results
    r = Patient.where(familyName: 'MPL record').first
    assert_equal 5, r.calculation_results.count, 'record should have 5 calculated results. 1 for the proportion measure and 4 for the stratified measure'
  end

  def record_demographics_equal?(record1, record2)
    r1 = record1
    r2 = record2
    r1.givenNames == r2.givenNames && r1.familyName == r2.familyName && r1.gender == r2.gender &&
      r1.qdmPatient.birthDatetime == r2.qdmPatient.birthDatetime && r1.race['code'] == r2.race['code'] && r1.ethnicity['code'] == r2.ethnicity['code']
  end

  def record_birthyear_equal?(record1, record2)
    record1.qdmPatient.birthDatetime.year == record2.qdmPatient.birthDatetime.year
  end

  def test_record_duplicate_randomization
    10.times do
      random = Random.new_seed
      prng1 = Random.new(random)
      prng2 = Random.new(random)

      r1 = Patient.new(familyName: 'Robert', givenNames: ['Johnson'])
      r1.qdmPatient.birthDatetime = DateTime.new(1985, 2, 18).utc
      r1.qdmPatient.dataElements << QDM::PatientCharacteristicRace.new(dataElementCodes: [{ 'code' => APP_CONSTANTS['randomization']['races'].sample(random: prng1)['code'], 'code_system' => 'cdcrec' }])
      r1.qdmPatient.dataElements << QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [{ 'code' => APP_CONSTANTS['randomization']['ethnicities'].sample(random: prng1)['code'], 'code_system' => 'cdcrec' }])
      r1.qdmPatient.dataElements << QDM::PatientCharacteristicSex.new(dataElementCodes: [{ 'code' => 'M', 'code_system' => 'AdministrativeGender' }])

      r2 = Patient.new(familyName: 'Robert', givenNames: ['Johnson'])
      r2.qdmPatient.birthDatetime = DateTime.new(1985, 2, 18).utc
      r2.qdmPatient.dataElements << QDM::PatientCharacteristicRace.new(dataElementCodes: [{ 'code' => APP_CONSTANTS['randomization']['races'].sample(random: prng2)['code'], 'code_system' => 'cdcrec' }])
      r2.qdmPatient.dataElements << QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [{ 'code' => APP_CONSTANTS['randomization']['ethnicities'].sample(random: prng2)['code'], 'code_system' => 'cdcrec' }])
      r2.qdmPatient.dataElements << QDM::PatientCharacteristicSex.new(dataElementCodes: [{ 'code' => 'M', 'code_system' => 'AdministrativeGender' }])

      assert(record_demographics_equal?(r1, r2), 'The two records should be equal')
      r1copy_set = r1.duplicate_randomization([], random: prng1)
      r2copy_set = r2.duplicate_randomization([], random: prng2)
      assert(record_demographics_equal?(r1copy_set[0], r2copy_set[0]), 'The two records should be equal')
      assert_not(record_demographics_equal?(r1, r1copy_set[0]), 'The two records should not be equal')
      assert(record_birthyear_equal?(r1, r1copy_set[0]), 'The two records should always have the same birthyear')
    end
  end

  def test_randomize_patient_name_or_birth_counts
    first_count = 0
    last_count = 0
    birthdate_count = 0
    100.times do
      random = Random.new_seed
      prng1 = Random.new(random)

      r1 = Patient.new(familyName: 'Robert', givenNames: ['Johnson'])
      r1.qdmPatient.birthDatetime = DateTime.new(1985, 2, 18).utc
      r1.qdmPatient.dataElements << QDM::PatientCharacteristicRace.new(dataElementCodes: [{ 'code' => APP_CONSTANTS['randomization']['races'].sample(random: prng1)['code'], 'code_system' => 'cdcrec' }])
      r1.qdmPatient.dataElements << QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [{ 'code' => APP_CONSTANTS['randomization']['ethnicities'].sample(random: prng1)['code'], 'code_system' => 'cdcrec' }])
      r1.qdmPatient.dataElements << QDM::PatientCharacteristicSex.new(dataElementCodes: [{ 'code' => 'M', 'code_system' => 'AdministrativeGender' }])

      clone_patient = r1.clone
      _patient, changed = r1.randomize_patient_name_or_birth(clone_patient, {}, [], random: prng1)

      first_count += 1 unless changed[:first].nil?
      last_count += 1 unless changed[:last].nil?
      next unless changed[:birthdate]

      birthdate_count += 1
      # Year should always remain unchanged
      assert(changed[:birthdate][0].year, changed[:birthdate][1].year)
      # Month should always remain unchanged
      assert(changed[:birthdate][0].month, changed[:birthdate][1].month)
      # Day should always be changed
      assert_not_equal(changed[:birthdate][0].day, changed[:birthdate][1].day)
    end
    # at least one first name should be changed
    assert first_count.positive?
    # at least one last name should be changed
    assert last_count.positive?
    # at least one birthdate should be changed
    assert birthdate_count.positive?
    # fewer than 10 birthdates should be changed (there should be ~5)
    # Padding in assert to account for randomness (count will be 13+ on ~0.15% of runs)
    assert birthdate_count < 13
  end

  def test_normalize_relevant_date_time2021
    @bundle.version = '2021.0.0'
    @bundle.save
    record = BundlePatient.new(familyName: 'normalize', givenNames: ['datetime'], bundleId: @bundle.id)
    QDM::Patient.create!(cqmPatient: record, birthDatetime: DateTime.new(1981, 6, 8, 4, 0, 0).utc)
    time_value = DateTime.new(2011, 3, 24, 20, 53, 20).utc
    record.qdmPatient.dataElements << QDM::AssessmentPerformed.new(id: 'assessment', relevantDatetime: time_value)
    assert_nil record.qdmPatient.dataElements.first.relevantPeriod

    record.normalize_date_times
    normalized_element = record.qdmPatient.dataElements.first
    # relevantPeriod should still be nil
    assert_nil normalized_element.relevantPeriod
  end

  def test_normalize_relevant_date_time_no_bundle
    record = BundlePatient.new(familyName: 'normalize', givenNames: ['datetime'])
    QDM::Patient.create!(cqmPatient: record, birthDatetime: DateTime.new(1981, 6, 8, 4, 0, 0).utc)
    time_value = DateTime.new(2011, 3, 24, 20, 53, 20).utc
    record.qdmPatient.dataElements << QDM::AssessmentPerformed.new(id: 'assessment', relevantDatetime: time_value)
    assert_nil record.qdmPatient.dataElements.first.relevantPeriod

    record.normalize_date_times
    normalized_element = record.qdmPatient.dataElements.first
    # relevantPeriod should still be nil
    assert_nil normalized_element.relevantPeriod
  end

  def test_normalize_relevant_date_time
    record = BundlePatient.new(familyName: 'normalize', givenNames: ['datetime'], bundleId: @bundle.id)
    QDM::Patient.create!(cqmPatient: record, birthDatetime: DateTime.new(1981, 6, 8, 4, 0, 0).utc)
    time_value = DateTime.new(2011, 3, 24, 20, 53, 20).utc
    record.qdmPatient.dataElements << QDM::AssessmentPerformed.new(id: 'assessment', relevantDatetime: time_value)
    assert_nil record.qdmPatient.dataElements.first.relevantPeriod

    record.normalize_date_times
    normalized_element = record.qdmPatient.dataElements.first
    assert normalized_element.relevantPeriod.is_a? QDM::Interval
    assert_equal time_value, normalized_element.relevantPeriod.low
    assert_equal time_value, normalized_element.relevantPeriod.high
    assert_equal time_value, normalized_element.relevantDatetime

    record.denormalize_date_times
    denormalized_element = record.qdmPatient.dataElements.first
    assert_nil denormalized_element.relevantPeriod
    assert_equal time_value, denormalized_element.relevantDatetime
  end

  def test_normalize_relevant_period
    record = BundlePatient.new(familyName: 'normalize', givenNames: ['period'], bundleId: @bundle.id)
    QDM::Patient.create!(cqmPatient: record, birthDatetime: DateTime.new(1981, 6, 8, 4, 0, 0).utc)
    time_value_start = DateTime.new(2011, 3, 24, 20, 53, 20).utc
    time_value_end = DateTime.new(2011, 3, 25, 20, 53, 20).utc
    time_interval = QDM::Interval.new(time_value_start, time_value_end)
    record.qdmPatient.dataElements << QDM::AssessmentPerformed.new(id: 'assessment', relevantPeriod: time_interval)
    assert_nil record.qdmPatient.dataElements.first.relevantDatetime

    record.normalize_date_times
    normalized_element = record.qdmPatient.dataElements.first
    assert normalized_element.relevantDatetime.is_a? DateTime
    assert_equal time_value_start, normalized_element.relevantPeriod.low
    assert_equal time_value_end, normalized_element.relevantPeriod.high
    assert_equal time_value_start, normalized_element.relevantDatetime

    record.denormalize_date_times
    denormalized_element = record.qdmPatient.dataElements.first
    assert_nil denormalized_element.relevantDatetime
    assert_equal time_value_start, denormalized_element.relevantPeriod.low
    assert_equal time_value_end, denormalized_element.relevantPeriod.high
  end

  def test_normalize_relevant_period_low_only
    record = BundlePatient.new(familyName: 'normalize', givenNames: ['period'], bundleId: @bundle.id)
    QDM::Patient.create!(cqmPatient: record, birthDatetime: DateTime.new(1981, 6, 8, 4, 0, 0).utc)
    time_value_start = DateTime.new(2011, 3, 24, 20, 53, 20).utc
    time_value_end = nil
    time_interval = QDM::Interval.new(time_value_start, time_value_end)
    record.qdmPatient.dataElements << QDM::AssessmentPerformed.new(id: 'assessment', relevantPeriod: time_interval)
    assert_nil record.qdmPatient.dataElements.first.relevantDatetime

    record.normalize_date_times
    normalized_element = record.qdmPatient.dataElements.first
    assert normalized_element.relevantDatetime.is_a? DateTime
    assert_equal time_value_start, normalized_element.relevantPeriod.low
    assert_nil normalized_element.relevantPeriod.high
    assert_equal time_value_start, normalized_element.relevantDatetime

    record.denormalize_date_times
    denormalized_element = record.qdmPatient.dataElements.first
    assert_nil denormalized_element.relevantDatetime
    assert_equal time_value_start, denormalized_element.relevantPeriod.low
    assert_nil denormalized_element.relevantPeriod.high
  end

  def test_normalize_relevant_period_high_only
    record = BundlePatient.new(familyName: 'normalize', givenNames: ['period'], bundleId: @bundle.id)
    QDM::Patient.create!(cqmPatient: record, birthDatetime: DateTime.new(1981, 6, 8, 4, 0, 0).utc)
    time_value_start = nil
    time_value_end = DateTime.new(2011, 3, 25, 20, 53, 20).utc
    time_interval = QDM::Interval.new(time_value_start, time_value_end)
    record.qdmPatient.dataElements << QDM::AssessmentPerformed.new(id: 'assessment', relevantPeriod: time_interval)
    assert_nil record.qdmPatient.dataElements.first.relevantDatetime

    record.normalize_date_times
    normalized_element = record.qdmPatient.dataElements.first
    assert normalized_element.relevantDatetime.is_a? DateTime
    assert_nil normalized_element.relevantPeriod.low
    assert_equal time_value_end, normalized_element.relevantPeriod.high
    assert_equal time_value_end, normalized_element.relevantDatetime

    record.denormalize_date_times
    denormalized_element = record.qdmPatient.dataElements.first
    assert_nil denormalized_element.relevantDatetime
    assert_nil denormalized_element.relevantPeriod.low
    assert_equal time_value_end, denormalized_element.relevantPeriod.high
  end

  def test_account_for_epoch_time_boundary
    # Birthdates on 1 January 1970 00:00 UTC will be shifted to 1 January 1970 00:01 UTC to avoid calculation issues
    record = BundlePatient.new(familyName: 'epoch', givenNames: ['boundary'], bundleId: @bundle.id)
    epoch_birth_datetime = DateTime.new(1970, 1, 1, 0, 0, 0).utc
    shifted_birth_datetime = DateTime.new(1970, 1, 1, 0, 0, 1).utc
    QDM::Patient.create!(cqmPatient: record, birthDatetime: epoch_birth_datetime)
    assert_equal shifted_birth_datetime, record.qdmPatient.birthDatetime
  end

  def test_preserve_birth_datetime
    # Birthdates not on 1 January 1970 00:00 UTC will be preserved
    record = BundlePatient.new(familyName: 'non epoch', givenNames: ['boundary'], bundleId: @bundle.id)
    original_birth_datetime = DateTime.new(1970, 2, 1, 0, 0, 0).utc
    QDM::Patient.create!(cqmPatient: record, birthDatetime: original_birth_datetime)
    assert_equal original_birth_datetime, record.qdmPatient.birthDatetime
  end
end
