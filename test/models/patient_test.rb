require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  def setup
    @bundle = FactoryBot.create(:static_bundle)
  end

  def test_record_knows_bundle
    patient = Patient.new(bundleId: @bundle.id)
    patient.save
    assert_equal @bundle, patient.bundle, 'A record should know what bundle it is associated with if any'
  end

  def test_record_should_be_able_to_find_original
    r1_extended_data = { medical_record_number: '1a' }
    r1 = Patient.new(extendedData: r1_extended_data, bundleId: @bundle.id)
    r1.save
    r2_extended_data = { medical_record_number: '1a', original_patient: r1.id }
    r2 = Patient.new(extendedData: r2_extended_data, bundleId: @bundle.id)
    r2.save
    assert_equal r1, r2.original_patient, 'Record should be able to find record it was cloned from'
  end

  def test_record_should_be_able_to_find_calculation_results
    r = Patient.where(familyName: 'MPL record').first
    assert_equal 1, r.calculation_results.count, 'record should have 1 calculated results'
  end

  def record_demographics_equal?(r1, r2)
    r1.givenNames == r2.givenNames && r1.familyName == r2.familyName && r1.gender == r2.gender &&
      r1.birthDatetime == r2.birthDatetime && r1.race['code'] == r2.race['code'] && r1.ethnicity['code'] == r2.ethnicity['code']
  end

  def record_birthyear_equal?(r1, r2)
    r1.birthDatetime.year == r2.birthDatetime.year
  end

  def test_record_duplicate_randomization
    10.times do
      random = Random.new_seed
      prng1 = Random.new(random)
      prng2 = Random.new(random)

      r1 = Patient.new(familyName: 'Robert', givenNames: ['Johnson'], birthDatetime: DateTime.new(1985, 2, 18).utc)
      r1.dataElements << QDM::PatientCharacteristicRace.new(dataElementCodes: [{ 'code' => APP_CONSTANTS['randomization']['races'].sample(random: prng1)['code'], 'code_system' => 'cdcrec' }])
      r1.dataElements << QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [{ 'code' => APP_CONSTANTS['randomization']['ethnicities'].sample(random: prng1)['code'], 'code_system' => 'cdcrec' }])
      r1.dataElements << QDM::PatientCharacteristicSex.new(dataElementCodes: [{ 'code' => 'M', 'code_system' => 'AdministrativeGender' }])

      r2 = Patient.new(familyName: 'Robert', givenNames: ['Johnson'], birthDatetime: DateTime.new(1985, 2, 18).utc)
      r2.dataElements << QDM::PatientCharacteristicRace.new(dataElementCodes: [{ 'code' => APP_CONSTANTS['randomization']['races'].sample(random: prng2)['code'], 'code_system' => 'cdcrec' }])
      r2.dataElements << QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [{ 'code' => APP_CONSTANTS['randomization']['ethnicities'].sample(random: prng2)['code'], 'code_system' => 'cdcrec' }])
      r2.dataElements << QDM::PatientCharacteristicSex.new(dataElementCodes: [{ 'code' => 'M', 'code_system' => 'AdministrativeGender' }])

      assert(record_demographics_equal?(r1, r2), 'The two records should be equal')
      r1copy_set = r1.duplicate_randomization(random: prng1)
      r2copy_set = r2.duplicate_randomization(random: prng2)
      assert(record_demographics_equal?(r1copy_set[0], r2copy_set[0]), 'The two records should be equal')
      assert_not(record_demographics_equal?(r1, r1copy_set[0]), 'The two records should not be equal')
      assert(record_birthyear_equal?(r1, r1copy_set[0]), 'The two records should always have the same birthyear')
    end
  end
end
