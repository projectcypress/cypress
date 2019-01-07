require 'test_helper'
require 'fileutils'

class DemographicsRandomizerTest < ActiveSupport::TestCase
  setup do
    @bundle = FactoryBot.create(:static_bundle)
    @given_names = ['Xyntash']
    @family_name = 'Zygadoo'
    @original_race_code = 'NA'
    @original_gender_code = 'M'
    @original_ethnicity_code = 'NA'
    @race = QDM::PatientCharacteristicRace.new(dataElementCodes: [{ 'code' => @original_race_code, 'codeSystem' => 'NA' }])
    @ethnicity = QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [{ 'code' => @original_ethnicity_code, 'codeSystem' => 'NA' }])
    @gender = QDM::PatientCharacteristicSex.new(dataElementCodes: [{ 'code' => @original_gender_code, 'codeSystem' => 'NA' }])
    @address = QDM::Address.new(
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
    ip = {}
    ip['codes'] = { 'NA' => 123 }
    ip['member_id'] = '123'
    ip['start_time'] = 0
    ip['type'] = 'NA'
    ip['name'] = 'NA'
    ip['payer'] = { 'name' => 'NA' }
    @insurance_provider = JSON.generate([ip])

    @record = Patient.new(
      givenNames: @given_names,
      familyName: @family_name,
      birthDatetime: DateTime.new(1981, 6, 8, 4, 0, 0).utc,
      dataElements: [@race, @gender, @ethnicity],
      extendedData: { 'insurance_providers' => @insurance_provider, 'addresses' => [@address] }
    )
    @record.bundleId = @bundle.id
    @prng = Random.new(Random.new_seed)
  end

  def test_randomize_name
    Cypress::DemographicsRandomizer.randomize_name(@record, @prng)
    assert_not_equal @given_names, @record.givenNames
    assert_not_equal @family_name, @record.familyName
    assert_equal @original_race_code, @record.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal @original_ethnicity_code, @record.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_equal [@address], @record['extendedData']['addresses']
    assert_equal @insurance_provider, @record['extendedData']['insurance_providers']
  end

  def test_randomize_race
    Cypress::DemographicsRandomizer.randomize_race(@record, @prng)
    assert_not_equal @original_race_code, @record.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal @given_names, @record.givenNames
    assert_equal @family_name, @record.familyName
    assert_equal @original_ethnicity_code, @record.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_equal [@address], @record['extendedData']['addresses']
    assert_equal @insurance_provider, @record['extendedData']['insurance_providers']
  end

  def test_randomize_ethnicity
    Cypress::DemographicsRandomizer.randomize_ethnicity(@record, @prng)
    assert_not_equal @original_ethnicity_code, @record.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_equal @given_names, @record.givenNames
    assert_equal @family_name, @record.familyName
    assert_equal @original_race_code, @record.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal [@address], @record['extendedData']['addresses']
    assert_equal @insurance_provider, @record['extendedData']['insurance_providers']
  end

  def test_randomize_address
    Cypress::DemographicsRandomizer.randomize_address(@record)
    addr = @record['extendedData']['addresses'][0]
    assert_not_equal @address, addr
    assert_not_equal @address.use, addr.use
    assert_not_equal @address.street, addr.street
    assert_not_equal @address.city, addr.city
    assert_not_equal @address.state, addr.state
    assert_not_equal @address.zip, addr.zip
    assert_not_equal @address.country, addr.country
    assert_equal @given_names, @record.givenNames
    assert_equal @family_name, @record.familyName
    assert_equal @original_race_code, @record.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal @original_ethnicity_code, @record.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_equal @insurance_provider, @record['extendedData']['insurance_providers']
  end

  def test_randomize_insurance_provider
    Cypress::DemographicsRandomizer.randomize_insurance_provider(@record)
    ip = JSON.parse(@record['extendedData']['insurance_providers'])[0]
    original_ip = JSON.parse(@insurance_provider)[0]
    assert_not_equal original_ip, ip
    assert_not_equal original_ip.codes, ip.codes
    assert_not_equal original_ip.name, ip.name
    assert_not_equal original_ip.type, ip.type
    assert_not_equal original_ip.payer.name, ip.payer.name
    assert_not_equal original_ip.member_id, ip.member_id
    assert_equal 10, ip.member_id.length
    assert_not_equal original_ip.start_time, ip.start_time
    assert ip.start_time >= @record.birthDatetime
    assert ip.start_time < Time.now.utc
    assert_payer_data_is_valid
    assert_equal @given_names, @record.givenNames
    assert_equal @family_name, @record.familyName
    assert_equal @original_race_code, @record.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_equal @original_ethnicity_code, @record.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_equal [@address], @record['extendedData']['addresses']
  end

  def assert_payer_data_is_valid
    ip = JSON.parse(@record['extendedData']['insurance_providers'])[0]
    assert %w[1 2 349].include? ip.codes['SOP'][0]
    case ip.codes['SOP'][0]
    when '1'
      assert_equal 'Medicare', ip.name
      assert_equal 'Medicare', ip.payer.name
      assert_equal 'MA', ip.type
    when '2'
      assert_equal 'Medicaid', ip.name
      assert_equal 'Medicaid', ip.payer.name
      assert_equal 'MC', ip.type
    when '349'
      assert_equal 'Other', ip.name
      assert_equal 'Other', ip.payer.name
      assert_equal 'OT', ip.type
    end
  end

  def test_randomize_all
    Cypress::DemographicsRandomizer.randomize(@record, @prng)
    assert_not_equal @given_names, @record.givenNames
    assert_not_equal @family_name, @record.familyName
    assert_not_equal @original_race_code, @record.get_data_elements('patient_characteristic', 'race').first.dataElementCodes.first['code']
    assert_not_equal @original_ethnicity_code, @record.get_data_elements('patient_characteristic', 'ethnicity').first.dataElementCodes.first['code']
    assert_not_equal [@address], @record['extendedData']['addresses']
    assert_not_equal [@insurance_provider], JSON.parse(@record['extendedData']['insurance_providers'])
  end
end
