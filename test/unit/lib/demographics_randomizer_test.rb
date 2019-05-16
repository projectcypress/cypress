require 'test_helper'
require 'fileutils'

class DemographicsRandomizerTest < ActiveSupport::TestCase
  setup do
    @bundle = FactoryBot.create(:static_bundle)
    @given_names = ['Xyntash']
    @family_name = 'Zygadoo'
    @original_race_code = 'NA'
    @original_gender_code = 'M'
    @original_payer_code = '1'
    @original_ethnicity_code = 'NA'
    @race = QDM::PatientCharacteristicRace.new(dataElementCodes: [{ 'code' => @original_race_code, 'codeSystem' => 'NA' }])
    @ethnicity = QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [{ 'code' => @original_ethnicity_code, 'codeSystem' => 'NA' }])
    @gender = QDM::PatientCharacteristicSex.new(dataElementCodes: [{ 'code' => @original_gender_code, 'codeSystem' => 'NA' }])
    @payer = QDM::PatientCharacteristicPayer.new(dataElementCodes: [{ 'code' => @original_payer_code, 'codeSystem' => 'NA' }], relevantPeriod: QDM::Interval.new(@start, nil))
    @address = CQM::Address.new(
      use: 'H',
      street: ['123 Tregslofsterlang Lane'],
      city: 'Rthysdambibob',
      state: 'AA',
      zip: '99999',
      country: 'ZZ'
    )
    setup_secondary_instances
  end

  def setup_secondary_instances
    @record = Patient.new(
      givenNames: @given_names,
      familyName: @family_name,
      addresses: [@address]
    )
    QDM::Patient.create!(tacomaPatient: @record, dataElements: [@race, @gender, @ethnicity, @payer], birthDatetime: DateTime.new(1981, 6, 8, 4, 0, 0).utc)
    @record.bundleId = @bundle.id
    @prng = Random.new(Random.new_seed)
  end

  def test_randomize_name
    Cypress::DemographicsRandomizer.randomize_name(@record, @prng)
    assert_not_equal @given_names, @record.givenNames
    assert_not_equal @family_name, @record.familyName
    assert_equal @original_race_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal @original_ethnicity_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_equal [@address], @record.addresses
    assert_equal @original_payer_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'payer').first.dataElementCodes.first['code']
  end

  def test_randomize_race
    Cypress::DemographicsRandomizer.randomize_race(@record, @prng)
    assert_not_equal @original_race_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal @given_names, @record.givenNames
    assert_equal @family_name, @record.familyName
    assert_equal @original_ethnicity_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_equal [@address], @record.addresses
    assert_equal @original_payer_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'payer').first.dataElementCodes.first['code']
  end

  def test_randomize_ethnicity
    Cypress::DemographicsRandomizer.randomize_ethnicity(@record, @prng)
    assert_not_equal @original_ethnicity_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_equal @given_names, @record.givenNames
    assert_equal @family_name, @record.familyName
    assert_equal @original_race_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal [@address], @record.addresses
    assert_equal @original_payer_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'payer').first.dataElementCodes.first['code']
  end

  def test_randomize_address
    Cypress::DemographicsRandomizer.randomize_address(@record)
    addr = @record.addresses[0]
    assert_not_equal @address, addr
    assert_not_equal @address.use, addr.use
    assert_not_equal @address.street, addr.street
    assert_not_equal @address.city, addr.city
    assert_not_equal @address.state, addr.state
    assert_not_equal @address.zip, addr.zip
    assert_not_equal @address.country, addr.country
    assert_equal @given_names, @record.givenNames
    assert_equal @family_name, @record.familyName
    assert_equal @original_race_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal @original_ethnicity_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_equal @original_payer_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'payer').first.dataElementCodes.first['code']
  end

  def test_randomize_birthdate
    bd = DateTime.new(1981, 6, 8, 4, 0, 0).utc
    patient = QDM::Patient.new(birthDatetime: bd)
    patient.dataElements << QDM::PatientCharacteristicBirthdate.new(birthDatetime: bd)
    Cypress::DemographicsRandomizer.randomize_birthdate(patient)
    assert_not_equal patient.birthDatetime, bd
    assert_equal patient.birthDatetime, patient.dataElements[0].birthDatetime
  end

  def test_randomize_payer
    Cypress::DemographicsRandomizer.randomize_payer(@record, @prng)
    assert_not_equal @original_payer_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'payer').first.dataElementCodes.first['code']
    assert_equal @given_names, @record.givenNames
    assert_equal @family_name, @record.familyName
    assert_equal @original_race_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal [@address], @record.addresses
  end

  def test_randomize_all
    Cypress::DemographicsRandomizer.randomize(@record, @prng)
    assert_not_equal @given_names, @record.givenNames
    assert_not_equal @family_name, @record.familyName
    assert_not_equal @original_race_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_not_equal @original_ethnicity_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_not_equal [@address], @record.addresses
    assert_not_equal [@original_payer_code], @record.qdmPatient.get_data_elements('patient_characteristic', 'payer').first.dataElementCodes.first['code']
  end
end
