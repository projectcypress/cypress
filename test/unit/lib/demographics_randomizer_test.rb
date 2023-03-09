# frozen_string_literal: true

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
    @original_email = 'xzygadoo1@example.com'
    @race = QDM::PatientCharacteristicRace.new(dataElementCodes: [{ 'code' => @original_race_code, 'codeSystem' => 'NA' }])
    @ethnicity = QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [{ 'code' => @original_ethnicity_code, 'codeSystem' => 'NA' }])
    @gender = QDM::PatientCharacteristicSex.new(dataElementCodes: [{ 'code' => @original_gender_code, 'codeSystem' => 'NA' }])
    @payer = QDM::PatientCharacteristicPayer.new(dataElementCodes: [{ 'code' => @original_payer_code, 'codeSystem' => 'NA' }], relevantPeriod: QDM::Interval.new(@start, nil))
    @patient_address = CQM::Address.new(
      use: 'B',
      street: ['123 Main Lane'],
      city: 'Portland',
      state: 'Maine',
      zip: '99999',
      country: 'ZZ'
    )
    @patient_telecom = CQM::Telecom.new(
      use: 'HP',
      value: 'tel:+1(555)555-2003'
    )
    setup_secondary_instances
  end

  def setup_secondary_instances
    @record = Patient.new(
      givenNames: @given_names,
      familyName: @family_name,
      addresses: [@patient_address],
      telecoms: [@patient_telecom],
      email: [@original_email]
    )
    QDM::Patient.create!(cqmPatient: @record, dataElements: [@race, @gender, @ethnicity, @payer], birthDatetime: DateTime.new(1981, 6, 8, 4, 0, 0).utc)
    @record.bundleId = @bundle.id
    @prng = Random.new(Random.new_seed)
  end

  def test_null_demographics
    @record = Patient.new(
      givenNames: @given_names,
      familyName: @family_name,
      addresses: [@patient_address],
      telecoms: [@patient_telecom]
    )
    QDM::Patient.create!(cqmPatient: @record, birthDatetime: DateTime.new(1981, 6, 8, 4, 0, 0).utc)
    @record.bundleId = @bundle.id
    @prng = Random.new(Random.new_seed)
    gender_exception = assert_raises(RuntimeError) do
      Cypress::DemographicsRandomizer.randomize_gender(@record, @prng)
    end
    race_exception = assert_raises(RuntimeError) do
      Cypress::DemographicsRandomizer.randomize_race(@record, @prng)
    end
    ethnicity_exception = assert_raises(RuntimeError) do
      Cypress::DemographicsRandomizer.randomize_ethnicity(@record, @prng)
    end
    payer_exception = assert_raises(RuntimeError) do
      Cypress::DemographicsRandomizer.randomize_payer(@record, @prng)
    end
    assert_equal('Cannot find gender element', gender_exception.message)
    assert_equal('Cannot find race element', race_exception.message)
    assert_equal('Cannot find ethnicity element', ethnicity_exception.message)
    assert_equal('Cannot find payer element', payer_exception.message)
  end

  def test_default_demographics
    @record = Patient.new(
      givenNames: @given_names,
      familyName: @family_name,
      addresses: [@patient_address],
      telecoms: [@patient_telecom]
    )
    QDM::Patient.create!(cqmPatient: @record, birthDatetime: DateTime.new(1981, 6, 8, 4, 0, 0).utc)
    @record.bundleId = @bundle.id
    Cypress::DemographicsRandomizer.assign_default_demographics(@record)
    Cypress::DemographicsRandomizer.update_demographic_codes(@record)
    assert @record.email
    assert_equal @record.gender, 'M'
    assert_equal @record.race, '2028-9'
    assert_equal @record.ethnicity, '2186-5'
    assert_equal @record.payer, '1'
  end

  def test_random_payer
    @record = Patient.new(
      givenNames: @given_names,
      familyName: @family_name,
      addresses: [@patient_address],
      telecoms: [@patient_telecom]
    )
    QDM::Patient.create!(cqmPatient: @record, birthDatetime: DateTime.new(1981, 6, 8, 4, 0, 0).utc)
    @record.bundleId = @bundle.id
    @prng = Random.new(Random.new_seed)
    payer_date = Cypress::DemographicsRandomizer.get_random_payer_start_date(@record, false, @prng)
    # If a patient only has a birthdate, the payer start time should be the birthdate
    assert_equal payer_date, @record.qdmPatient.birthDatetime
    assessment_performed = QDM::AssessmentPerformed.new(id: 'assessment', authorDatetime: DateTime.new(2011, 3, 24, 20, 53, 20).utc)
    @record.qdmPatient.dataElements.push assessment_performed
    payer_date_with_author_times = Cypress::DemographicsRandomizer.get_random_payer_start_date(@record, false, @prng)
    # If a patient has a birthdate and an element with an authordate, the payer start time should be between the birthdate and authorDatetime
    assert payer_date_with_author_times > @record.qdmPatient.birthDatetime
    assert payer_date_with_author_times < assessment_performed.authorDatetime
    # If a patient has medicare, the payer start time should be the month when the patient turns 65
    payer_date_with_medicare = Cypress::DemographicsRandomizer.get_random_payer_start_date(@record, true, @prng)
    assert_equal payer_date_with_medicare.year, @record.qdmPatient.birthDatetime.year + 65
    assert_equal payer_date_with_medicare.month, @record.qdmPatient.birthDatetime.month
    assert_equal payer_date_with_medicare.day, 1
  end

  def test_randomize_name
    Cypress::DemographicsRandomizer.randomize_name(@record, @prng)
    assert_not_equal @given_names, @record.givenNames
    assert_not_equal @family_name, @record.familyName
    assert_not_equal @original_email, @record.email
    assert_equal @original_race_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal @original_ethnicity_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_equal [@patient_address], @record.addresses
    assert_equal [@patient_telecom], @record.telecoms
    assert_equal @original_payer_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'payer').first.dataElementCodes.first['code']
  end

  def test_randomize_multiple_names
    original_male_first = NAMES_RANDOM['first']['M']
    original_female_first = NAMES_RANDOM['first']['F']
    original_last = NAMES_RANDOM['first']['F']
    10.times do
      NAMES_RANDOM['first']['M'] = ['Marion']
      NAMES_RANDOM['first']['F'] = %w[Marion Jill]
      NAMES_RANDOM['last'] = ['Smith']
      patient_list = [@record]
      record1 = @record.clone
      record2 = @record.clone
      record3 = @record.clone
      record3.qdmPatient.get_data_elements('patient_characteristic', 'gender').first.dataElementCodes.first['code'] = 'F'
      Cypress::DemographicsRandomizer.randomize_name(record1, @prng, patient_list)
      patient_list << record1
      NAMES_RANDOM['first']['M'] = %w[Marion Jake]
      Cypress::DemographicsRandomizer.randomize_name(record2, @prng, patient_list)
      patient_list << record2
      Cypress::DemographicsRandomizer.randomize_name(record3, @prng, patient_list)
      patient_list << record3
      assert_equal ['Marion'], record1.givenNames
      assert_equal ['Jake'], record2.givenNames
      assert_equal ['Jill'], record3.givenNames
    end
    NAMES_RANDOM['first']['M'] = original_male_first
    NAMES_RANDOM['first']['F'] = original_female_first
    NAMES_RANDOM['last'] = original_last
  end

  def test_randomize_race
    Cypress::DemographicsRandomizer.randomize_race(@record, @prng)
    assert_not_equal @original_race_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal @given_names, @record.givenNames
    assert_equal @family_name, @record.familyName
    assert_equal @original_ethnicity_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_equal [@patient_address], @record.addresses
    assert_equal [@patient_telecom], @record.telecoms
    assert_equal @original_payer_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'payer').first.dataElementCodes.first['code']
  end

  def test_randomize_ethnicity
    Cypress::DemographicsRandomizer.randomize_ethnicity(@record, @prng)
    assert_not_equal @original_ethnicity_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_equal @given_names, @record.givenNames
    assert_equal @family_name, @record.familyName
    assert_equal @original_race_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal [@patient_address], @record.addresses
    assert_equal [@patient_telecom], @record.telecoms
    assert_equal @original_payer_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'payer').first.dataElementCodes.first['code']
  end

  def test_randomize_address
    Cypress::DemographicsRandomizer.randomize_address(@record)
    addr = @record.addresses[0]
    assert_not_equal @patient_address, addr
    assert_not_equal @patient_address.use, addr.use
    assert_not_equal @patient_address.street, addr.street
    assert_not_equal @patient_address.city, addr.city
    assert_not_equal @patient_address.state, addr.state
    assert_not_equal @patient_address.zip, addr.zip
    assert_not_equal @patient_address.country, addr.country
    assert_not_equal @patient_telecom.value, @record.telecoms[0].value

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
    assert_equal [@patient_address], @record.addresses
    assert_equal [@patient_telecom], @record.telecoms
  end

  def test_randomize_all
    Cypress::DemographicsRandomizer.randomize(@record, @prng)
    assert_not_equal @given_names, @record.givenNames
    assert_not_equal @family_name, @record.familyName
    assert_not_equal @original_race_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_not_equal @original_ethnicity_code, @record.qdmPatient.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_not_equal [@patient_address], @record.addresses
    assert_not_equal [@patient_telecom], @record.telecoms
    assert_not_equal [@original_payer_code], @record.qdmPatient.get_data_elements('patient_characteristic', 'payer').first.dataElementCodes.first['code']
  end
end
