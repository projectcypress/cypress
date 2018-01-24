require 'test_helper'

class ClinicalRandomizerTest < ActiveSupport::TestCase
  setup do

    @record = Record.new(first: 'Foo', last: 'Bar')
    @bundle = FactoryGirl.create(:static_bundle)
    @bundle.measure_period_start = 1_293_840_000
    @bundle.effective_date = 1_325_375_999
    @bundle.save!
    @record.bundle_id = @bundle.id

    @record.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record.encounters.push Encounter.new(start_time: 1_317_513_599)
    @record.save!

    @record_2 = Record.new(first: 'Bar', last: 'Foo')
    @record_2.bundle_id = @bundle.id
    @record_2.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record_2.procedures.push Procedure.new(start_time: 1_317_513_599)
    @record_2.conditions.push Condition.new(start_time: 1_317_513_600)
    @record_2.save!

    @record_3 = Record.new(first: 'Insurance', last: 'Test')
    @record_3.bundle_id = @bundle.id
    @record_3.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record_3.insurance_providers.push InsuranceProvider.new(start_time: @bundle.measure_period_start)
    @record_3.save!

    @record_4 = Record.new(first: 'SplitDate', last: 'Same')
    @record_4.bundle_id = @bundle.id
    @record_4.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record_4.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record_4.insurance_providers.push InsuranceProvider.new(start_time: @bundle.measure_period_start)
    @record_4.save!

    @record_5 = Record.new(first: 'SplitDate', last: 'Same_plus')
    @record_5.bundle_id = @bundle.id
    @record_5.encounters.push Encounter.new(start_time: 1_301_000_000)
    @record_5.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record_5.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record_5.encounters.push Encounter.new(start_time: 1_302_000_000)
    @record_5.insurance_providers.push InsuranceProvider.new(start_time: @bundle.measure_period_start)
    @record_5.save!
  end

  def test_split_by_date
    date = Cypress::ClinicalRandomizer.find_split_date(@record, @bundle.effective_date, @bundle.measure_period_start, Random.new)
    assert date > @bundle.measure_period_start, 'Split date must be during the measurement period'
    assert date < @bundle.effective_date, 'Split date must be before the effective date'
  end

  def test_randomize_by_date
    r1, r2 = Cypress::ClinicalRandomizer.split_by_date(@record, @bundle.effective_date, @bundle.measure_period_start, Random.new)

    assert_equal r1.entries.length, 1, 'First split record should only have 1 entry'
    assert_equal r2.entries.length, 1, 'Second split record should only have 1 entry'
  end

  def test_find_dates
    detect_date = 1_301_615_999

    assert_equal Cypress::ClinicalRandomizer.find_first_date_after(@record.entries, detect_date), 1_317_513_599, 'Should return the only entry after the detect_date'
    assert_equal Cypress::ClinicalRandomizer.find_last_date_before(@record.entries, detect_date), 1_301_615_999, 'Should return the only entry before the detect_date'
  end

  def test_randomize_by_type
    record_1, record_2 = Cypress::ClinicalRandomizer.split_by_type(@record_2, @bundle.effective_date, @bundle.measure_period_start, Random.new)

    assert record_1.entries.count > 0, 'Record_1 should have at least 1 entry'
    assert record_2.entries.count > 0, 'Record_2 should have at least 1 entry'
    # This gets the unique set of types for each record's entries, then gets the intersection of them.
    # Ideally the arrays would be completely distinct, e.g. the intersection would be an empty set.
    assert_equal record_1.entries.collect(&:_type).uniq & record_2.entries.collect(&:_type).uniq, [], 'Records contain elements of the same type'
    assert_equal @record_2.entries.collect(&:_type).uniq.sort, (record_1.entries.collect(&:_type).uniq + record_2.entries.collect(&:_type).uniq).sort, 'Records should contain all the types in the parent record'

    record_1, record_2 = Cypress::ClinicalRandomizer.split_by_type(@record, @bundle.effective_date, @bundle.measure_period_start, Random.new)
    assert_equal record_1.entries.length, 1, 'First split record should have 1 entry if it falls back to split_by_date'
    assert_equal record_2.entries.length, 1, 'Second split record should only have 1 entry if it falls back to split_by_date'
  end

  def test_randomize
    record_1, record_2 = Cypress::ClinicalRandomizer.randomize(@record, @bundle.effective_date, @bundle.measure_period_start, random: Random.new)

    assert_not_nil record_1, 'Records should not be nil'
    assert_not_nil record_2, 'Records should not be nil'
  end

  def test_add_insurance_provider_split_by_date
    record_1, record_2 = Cypress::ClinicalRandomizer.split_by_date(@record_3, @bundle.effective_date, @bundle.measure_period_start, Random.new)
    assert_equal 1, record_1.insurance_providers.length, 'Record should have an insurance provider'
    assert_equal 1, record_2.insurance_providers.length, 'Record should have an insurance provider'
  end

  def test_add_insurance_provider_split_by_type
    record_1, record_2 = Cypress::ClinicalRandomizer.split_by_type(@record_3, @bundle.effective_date, @bundle.measure_period_start, Random.new)
    assert_equal 1, record_1.insurance_providers.length, 'Record should have an insurance provider'
    assert_equal 1, record_2.insurance_providers.length, 'Record should have an insurance provider'
  end

  def test_entries_on_split_date
    record_1, record_2 = Cypress::ClinicalRandomizer.split_by_date(@record_4, @bundle.effective_date, @bundle.measure_period_start, Random.new)

    assert_equal 3, record_1.entries.length, 'Record should have both entries (and a payer)'
    assert_equal 1, record_2.entries.length, 'Second record should not have entries (other than payer)'

    assert_equal 1, record_1.insurance_providers.length, 'Record 1 should have a payer'
    assert_equal 1, record_2.insurance_providers.length, 'Record 2 should have a payer'
  end

  def test_entries_on_split_date_plus
    record_1, record_2 = Cypress::ClinicalRandomizer.split_by_date(@record_5, @bundle.effective_date, @bundle.measure_period_start, Random.new)

    assert_equal 6, record_1.entries.length + record_2.entries.length, 'There should be 6 entries total (4 entries plus both payers)'

    assert record_1.entries.length >= 2, 'Record 1 should have at least 1 entry besides the payer'
    assert record_2.entries.length >= 2, 'Record 1 should have at least 1 entry besides the payer'

    assert_equal 1, record_1.insurance_providers.length, 'Record 1 should have a payer'
    assert_equal 1, record_2.insurance_providers.length, 'Record 2 should have a payer'
  end
end
