require 'test_helper'
require 'fileutils'

class DemographicsRandomizerTest < ActiveSupport::TestCase
  setup do
    @bundle = FactoryBot.create(:static_bundle)
    @first = 'Xyntash'
    @last = 'Zygadoo'
    @race = { 'code' => 'NA', 'name' => 'NA', 'codeSystem' => 'NA' }
    @ethnicity = { 'code' => 'NA', 'name' => 'NA', 'codeSystem' => 'NA' }
    @address = Address.new(
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
    @insurance_provider = InsuranceProvider.new(
      codes: { 'NA' => 123 },
      name: 'NA',
      type: 'NA',
      payer: Organization.new(name: 'NA'),
      member_id: '123',
      start_time: 0
    )
    @record = Record.new(
      first: @first,
      last: @last,
      birthdate: 360_820_800,
      gender: 'M',
      race: @race,
      ethnicity: @ethnicity,
      addresses: [@address],
      insurance_providers: [@insurance_provider]
    )
    @record.bundle_id = @bundle.id
    @prng = Random.new(Random.new_seed)
  end

  def test_randomize_name
    Cypress::DemographicsRandomizer.randomize_name(@record, @prng)
    assert_not_equal @first, @record.first
    assert_not_equal @last, @record.last
    assert_equal @race, @record.race
    assert_equal @ethnicity, @record.ethnicity
    assert_equal [@address], @record.addresses
    assert_equal [@insurance_provider], @record.insurance_providers
  end

  def test_randomize_race
    Cypress::DemographicsRandomizer.randomize_race(@record, @prng)
    assert_not_equal @race, @record.race
    assert_equal @first, @record.first
    assert_equal @last, @record.last
    assert_equal @ethnicity, @record.ethnicity
    assert_equal [@address], @record.addresses
    assert_equal [@insurance_provider], @record.insurance_providers
  end

  def test_randomize_ethnicity
    Cypress::DemographicsRandomizer.randomize_ethnicity(@record, @prng)
    assert_not_equal @ethnicity, @record.ethnicity
    assert_equal @first, @record.first
    assert_equal @last, @record.last
    assert_equal @race, @record.race
    assert_equal [@address], @record.addresses
    assert_equal [@insurance_provider], @record.insurance_providers
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
    assert_equal @first, @record.first
    assert_equal @last, @record.last
    assert_equal @race, @record.race
    assert_equal @ethnicity, @record.ethnicity
    assert_equal [@insurance_provider], @record.insurance_providers
  end

  def test_randomize_insurance_provider
    Cypress::DemographicsRandomizer.randomize_insurance_provider(@record)
    ip = @record.insurance_providers[0]
    assert_not_equal @insurance_provider, ip
    assert_not_equal @insurance_provider.codes, ip.codes
    assert_not_equal @insurance_provider.name, ip.name
    assert_not_equal @insurance_provider.type, ip.type
    assert_not_equal @insurance_provider.payer.name, ip.payer.name
    assert_not_equal @insurance_provider.member_id, ip.member_id
    assert_equal 10, ip.member_id.length
    assert_not_equal @insurance_provider.start_time, ip.start_time
    assert ip.start_time >= @record.birthdate
    assert ip.start_time < Time.now.to_i
    assert_payer_data_is_valid
    assert_equal @first, @record.first
    assert_equal @last, @record.last
    assert_equal @race, @record.race
    assert_equal @ethnicity, @record.ethnicity
    assert_equal [@address], @record.addresses
  end

  def assert_payer_data_is_valid
    ip = @record.insurance_providers[0]
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
    assert_not_equal @first, @record.first
    assert_not_equal @last, @record.last
    assert_not_equal @race, @record.race
    assert_not_equal @ethnicity, @record.ethnicity
    assert_not_equal [@address], @record.addresses
    assert_not_equal [@insurance_provider], @record.insurance_providers
  end
end
