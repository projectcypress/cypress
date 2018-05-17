require 'test_helper'

class ClinicalRandomizerTest < ActiveSupport::TestCase
  setup do
    @record = Record.new(first: 'Foo', last: 'Bar')
    @bundle = FactoryBot.create(:static_bundle)
    @bundle.measure_period_start = 1_293_840_000
    @bundle.effective_date = 1_325_375_999
    @bundle.save!
    @record.bundle_id = @bundle.id

    @record.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record.encounters.push Encounter.new(start_time: 1_317_513_599)
    @record.save!

    @record2 = Record.new(first: 'Bar', last: 'Foo')
    @record2.bundle_id = @bundle.id
    @record2.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record2.procedures.push Procedure.new(start_time: 1_317_513_599)
    @record2.conditions.push Condition.new(start_time: 1_317_513_600)
    @record2.save!

    setup_secondary_instances
  end

  def setup_secondary_instances
    @record3 = Record.new(first: 'Insurance', last: 'Test')
    @record3.bundle_id = @bundle.id
    @record3.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record3.insurance_providers.push InsuranceProvider.new(start_time: @bundle.measure_period_start)
    @record3.save!

    @record4 = Record.new(first: 'SplitDate', last: 'Same')
    @record4.bundle_id = @bundle.id
    @record4.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record4.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record4.insurance_providers.push InsuranceProvider.new(start_time: @bundle.measure_period_start)
    @record4.save!

    @record5 = Record.new(first: 'SplitDate', last: 'Same_plus')
    @record5.bundle_id = @bundle.id
    @record5.encounters.push Encounter.new(start_time: 1_301_000_000)
    @record5.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record5.encounters.push Encounter.new(start_time: 1_301_615_999)
    @record5.encounters.push Encounter.new(start_time: 1_302_000_000)
    @record5.insurance_providers.push InsuranceProvider.new(start_time: @bundle.measure_period_start)
    @record5.save!
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
    record1, record2 = Cypress::ClinicalRandomizer.split_by_type(@record2, @bundle.effective_date, @bundle.measure_period_start, Random.new)

    assert record1.entries.count.positive?, 'Record1 should have at least 1 entry'
    assert record2.entries.count.positive?, 'Record2 should have at least 1 entry'
    # This gets the unique set of types for each record's entries, then gets the intersection of them.
    # Ideally the arrays would be completely distinct, e.g. the intersection would be an empty set.
    assert_equal record1.entries.collect(&:_type).uniq & record2.entries.collect(&:_type).uniq, [], 'Records contain elements of the same type'
    assert_equal @record2.entries.collect(&:_type).uniq.sort, (record1.entries.collect(&:_type).uniq + record2.entries.collect(&:_type).uniq).sort, 'Records should contain all the types in the parent record'

    record1, record2 = Cypress::ClinicalRandomizer.split_by_type(@record, @bundle.effective_date, @bundle.measure_period_start, Random.new)
    assert_equal record1.entries.length, 1, 'First split record should have 1 entry if it falls back to split_by_date'
    assert_equal record2.entries.length, 1, 'Second split record should only have 1 entry if it falls back to split_by_date'
  end

  def test_randomize
    record1, record2 = Cypress::ClinicalRandomizer.randomize(@record, @bundle.effective_date, @bundle.measure_period_start, random: Random.new)

    assert_not_nil record1, 'Records should not be nil'
    assert_not_nil record2, 'Records should not be nil'
  end

  def test_add_insurance_provider_split_by_date
    record1, record2 = Cypress::ClinicalRandomizer.split_by_date(@record3, @bundle.effective_date, @bundle.measure_period_start, Random.new)
    assert_equal 1, record1.insurance_providers.length, 'Record should have an insurance provider'
    assert_equal 1, record2.insurance_providers.length, 'Record should have an insurance provider'
  end

  def test_add_insurance_provider_split_by_type
    record1, record2 = Cypress::ClinicalRandomizer.split_by_type(@record3, @bundle.effective_date, @bundle.measure_period_start, Random.new)
    assert_equal 1, record1.insurance_providers.length, 'Record should have an insurance provider'
    assert_equal 1, record2.insurance_providers.length, 'Record should have an insurance provider'
  end

  def test_entries_on_split_date
    record1, record2 = Cypress::ClinicalRandomizer.split_by_date(@record4, @bundle.effective_date, @bundle.measure_period_start, Random.new)

    assert_equal 3, record1.entries.length, 'Record should have both entries (and a payer)'
    assert_equal 1, record2.entries.length, 'Second record should not have entries (other than payer)'

    assert_equal 1, record1.insurance_providers.length, 'Record 1 should have a payer'
    assert_equal 1, record2.insurance_providers.length, 'Record 2 should have a payer'
  end

  def test_entries_on_split_date_plus
    record1, record2 = Cypress::ClinicalRandomizer.split_by_date(@record5, @bundle.effective_date, @bundle.measure_period_start, Random.new)

    assert_equal 6, record1.entries.length + record2.entries.length, 'There should be 6 entries total (4 entries plus both payers)'

    assert record1.entries.length >= 2, 'Record 1 should have at least 1 entry besides the payer'
    assert record2.entries.length >= 2, 'Record 1 should have at least 1 entry besides the payer'

    assert_equal 1, record1.insurance_providers.length, 'Record 1 should have a payer'
    assert_equal 1, record2.insurance_providers.length, 'Record 2 should have a payer'
  end
end
