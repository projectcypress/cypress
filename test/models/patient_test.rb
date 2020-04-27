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

  def record_demographics_equal?(r1, r2)
    r1.givenNames == r2.givenNames && r1.familyName == r2.familyName && r1.gender == r2.gender &&
      r1.qdmPatient.birthDatetime == r2.qdmPatient.birthDatetime && r1.race['code'] == r2.race['code'] && r1.ethnicity['code'] == r2.ethnicity['code']
  end

  def record_birthyear_equal?(r1, r2)
    r1.qdmPatient.birthDatetime.year == r2.qdmPatient.birthDatetime.year
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
    # Padding in assert to account for randomness
    assert birthdate_count < 10
  end
end
