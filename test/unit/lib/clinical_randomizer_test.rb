require 'test_helper'

class ClinicalRandomizerTest < ActiveSupport::TestCase
  setup do
    @patient = Patient.new(givenNames: ['Foo'], familyName: 'Bar')
    @bundle = FactoryBot.create(:static_bundle)
    @start = DateTime.new(2011, 1, 1, 0, 0, 0).utc
    @end = DateTime.new(2011, 12, 31, 23, 59, 59).utc
    @bundle.measure_period_start = 1_293_840_000
    @bundle.effective_date = 1_325_375_999
    @patient.bundleId = @bundle.id

    @patient.dataElements.push QDM::EncounterPerformed.new(relevantPeriod: QDM::Interval.new(DateTime.new(2011, 3, 31, 23, 59, 59).utc, nil))
    @patient.dataElements.push QDM::EncounterPerformed.new(relevantPeriod: QDM::Interval.new(DateTime.new(2011, 10, 1, 23, 59, 59).utc, nil))
    @patient.save!

    @patient2 = Patient.new(givenNames: ['Bar'], familyName: 'Foo')
    @patient2.bundleId = @bundle.id
    @patient2.dataElements.push QDM::EncounterPerformed.new(relevantPeriod: QDM::Interval.new(DateTime.new(2011, 3, 31, 23, 59, 59).utc, nil))
    @patient2.dataElements.push QDM::ProcedurePerformed.new(relevantPeriod: QDM::Interval.new(DateTime.new(2011, 10, 1, 23, 59, 59).utc, nil))
    @patient2.dataElements.push QDM::Diagnosis.new(prevalencePeriod: QDM::Interval.new(DateTime.new(2011, 10, 2, 0, 0, 0).utc, nil))
    @patient2.save!

    setup_secondary_instances
  end

  def setup_secondary_instances
    @patient3 = Patient.new(givenNames: ['Insurance'], familyName: 'Test')
    @patient3.bundleId = @bundle.id
    @patient3.dataElements.push QDM::EncounterPerformed.new(relevantPeriod: QDM::Interval.new(DateTime.new(2011, 3, 31, 23, 59, 59).utc, nil))
    @patient3.extendedData = { 'insurance_providers' => JSON.generate([{ start_time: @start }]) }
    @patient3.save!

    @patient4 = Patient.new(givenNames: ['SplitDate'], familyName: 'Same')
    @patient4.bundleId = @bundle.id
    @patient4.dataElements.push QDM::EncounterPerformed.new(relevantPeriod: QDM::Interval.new(DateTime.new(2011, 3, 31, 23, 59, 59).utc, nil))
    @patient4.dataElements.push QDM::EncounterPerformed.new(relevantPeriod: QDM::Interval.new(DateTime.new(2011, 3, 31, 23, 59, 59).utc, nil))
    @patient4.extendedData = { 'insurance_providers' => JSON.generate([{ start_time: @start }]) }
    @patient4.save!

    @patient5 = Patient.new(givenNames: ['SplitDate'], familyName: 'Same_plus')
    @patient5.bundleId = @bundle.id
    @patient5.dataElements.push QDM::EncounterPerformed.new(relevantPeriod: QDM::Interval.new(DateTime.new(2011, 3, 24, 20, 53, 20).utc, nil))
    @patient5.dataElements.push QDM::EncounterPerformed.new(relevantPeriod: QDM::Interval.new(DateTime.new(2011, 3, 31, 23, 59, 59).utc, nil))
    @patient5.dataElements.push QDM::EncounterPerformed.new(relevantPeriod: QDM::Interval.new(DateTime.new(2011, 3, 31, 23, 59, 59).utc, nil))
    @patient5.dataElements.push QDM::EncounterPerformed.new(relevantPeriod: QDM::Interval.new(DateTime.new(2011, 4, 5, 10, 40, 0).utc, nil))
    @patient5.extendedData = { 'insurance_providers' => JSON.generate([{ start_time: @start }]) }
    @patient5.save!
  end

  def test_split_by_date
    date = Cypress::ClinicalRandomizer.find_split_date(@patient, @end, @start, Random.new)
    assert date > @start, 'Split date must be during the measurement period'
    assert date < @end, 'Split date must be before the effective date'
  end

  def test_randomize_by_date
    r1, r2 = Cypress::ClinicalRandomizer.split_by_date(@patient, @end, @start, Random.new)

    assert_equal r1.dataElements.length, 1, 'First split record should only have 1 entry'
    assert_equal r2.dataElements.length, 1, 'Second split record should only have 1 entry'
  end

  def test_find_dates
    detect_date = DateTime.new(2011, 3, 31, 23, 59, 59).utc
    assert_equal Cypress::ClinicalRandomizer.find_first_date_after(@patient.dataElements, detect_date), DateTime.new(2011, 10, 1, 23, 59, 59).utc, 'Should return the only entry after the detect_date'
    assert_equal Cypress::ClinicalRandomizer.find_last_date_before(@patient.dataElements, detect_date), DateTime.new(2011, 3, 31, 23, 59, 59).utc, 'Should return the only entry before the detect_date'
  end

  def test_randomize_by_type
    record1, record2 = Cypress::ClinicalRandomizer.split_by_type(@patient2, @end, @start, Random.new)

    assert record1.dataElements.size.positive?, 'Record1 should have at least 1 entry'
    assert record2.dataElements.size.positive?, 'Record2 should have at least 1 entry'
    # This gets the unique set of types for each record's entries, then gets the intersection of them.
    # Ideally the arrays would be completely distinct, e.g. the intersection would be an empty set.
    assert_equal record1.dataElements.collect(&:_type).uniq & record2.dataElements.collect(&:_type).uniq, [], 'Records contain elements of the same type'
    assert_equal @patient2.dataElements.collect(&:_type).uniq.sort, (record1.dataElements.collect(&:_type).uniq + record2.dataElements.collect(&:_type).uniq).sort, 'Records should contain all the types in the parent record'

    record1, record2 = Cypress::ClinicalRandomizer.split_by_type(@patient, @end, @start, Random.new)
    assert_equal record1.dataElements.length, 1, 'First split record should have 1 entry if it falls back to split_by_date'
    assert_equal record2.dataElements.length, 1, 'Second split record should only have 1 entry if it falls back to split_by_date'
  end

  def test_randomize
    record1, record2 = Cypress::ClinicalRandomizer.randomize(@patient, @end, @start, random: Random.new)

    assert_not_nil record1, 'Records should not be nil'
    assert_not_nil record2, 'Records should not be nil'
  end

  def test_add_insurance_provider_split_by_date
    record1, record2 = Cypress::ClinicalRandomizer.split_by_date(@patient3, @end, @start, Random.new)
    assert_equal 1, JSON.parse(record1.extendedData['insurance_providers']).length, 'Record should have an insurance provider'
    assert_equal 1, JSON.parse(record2.extendedData['insurance_providers']).length, 'Record should have an insurance provider'
  end

  def test_add_insurance_provider_split_by_type
    record1, record2 = Cypress::ClinicalRandomizer.split_by_type(@patient3, @end, @start, Random.new)
    assert_equal 1, JSON.parse(record1.extendedData['insurance_providers']).length, 'Record should have an insurance provider'
    assert_equal 1, JSON.parse(record2.extendedData['insurance_providers']).length, 'Record should have an insurance provider'
  end

  def test_entries_on_split_date
    record1, record2 = Cypress::ClinicalRandomizer.split_by_date(@patient4, @end, @start, Random.new)

    assert_equal 2, record1.dataElements.length, 'Record should have both entries (and a payer)'
    assert_equal 0, record2.dataElements.length, 'Second record should not have entries (other than payer)'

    assert_equal 1, JSON.parse(record1.extendedData['insurance_providers']).length, 'Record 1 should have a payer'
    assert_equal 1, JSON.parse(record2.extendedData['insurance_providers']).length, 'Record 2 should have a payer'
  end

  def test_entries_on_split_date_plus
    record1, record2 = Cypress::ClinicalRandomizer.split_by_date(@patient5, @end, @start, Random.new)

    assert_equal 4, record1.dataElements.length + record2.dataElements.length, 'There should be 4 entries total'

    assert record1.dataElements.length >= 1, 'Record 1 should have at least 1 entry'
    assert record2.dataElements.length >= 1, 'Record 1 should have at least 1 entry'

    assert_equal 1, JSON.parse(record1.extendedData['insurance_providers']).length, 'Record 1 should have a payer'
    assert_equal 1, JSON.parse(record2.extendedData['insurance_providers']).length, 'Record 2 should have a payer'
  end
end
