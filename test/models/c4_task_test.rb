require 'test_helper'
# rubocop:disable Metrics/ClassLength
class C4TaskTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  def setup
    collection_fixtures('product_tests', 'bundles',
                        'records', 'health_data_standards_svs_value_sets')

    @product_test = ProductTest.find('51703a883054cf84390000d3')

    @all_records = @product_test.records.to_a
  end

  def test_create
    assert @product_test.tasks.create({}, C4Task)
  end

  # def test_after_create
  #   # taken from measure eval test so that the MEJ shouldnt error out
  #   QME::QualityReport.any_instance.stubs(:result).returns(@result)
  #   QME::QualityReport.any_instance.stubs(:calculated?).returns(true)

  #   task = @product_test.tasks.create({}, C4Task)
  #   task.after_create
  # end

  def test_filter_gender
    selected_gender = %w(M F).sample
    filters = { 'genders' => [selected_gender] }

    task = @product_test.tasks.create({ 'options' => { 'filters' => filters } }, C4Task)
    filter = task.patient_cache_filter

    assert filter.count == 1 && filter['genders']
  end

  def test_filter_race
    selected_race = %w(2106-3 2028-9 2054-5).sample
    filters = { 'races' => [selected_race] }

    task = @product_test.tasks.create({ 'options' => { 'filters' => filters } }, C4Task)
    filter = task.patient_cache_filter

    assert filter.count == 1 && filter['races']
  end

  def test_filter_ethnicity
    selected_ethn = %w(2186-5 2135-2).sample
    filters = { 'ethnicities' => [selected_ethn] }

    task = @product_test.tasks.create({ 'options' => { 'filters' => filters } }, C4Task)
    filter = task.patient_cache_filter

    assert filter.count == 1 && filter['ethnicities']
  end

  def test_filter_age_max
    age = Random.rand(100)
    filters = { 'age' => { 'max' => age } }

    task = @product_test.tasks.create({ 'options' => { 'filters' => filters } }, C4Task)
    filter = task.patient_cache_filter

    assert filter.count == 1 && filter['patients']
  end

  def test_filter_age_min
    age = Random.rand(100)
    filters = { 'age' => { 'min' => age } }

    task = @product_test.tasks.create({ 'options' => { 'filters' => filters } }, C4Task)
    filter = task.patient_cache_filter

    assert filter.count == 1 && filter['patients']
  end

  def test_filter_payer
    selected_payer = %w('Medicaid Medicare Other).sample
    filters = { 'payers' => [selected_payer] }

    task = @product_test.tasks.create({ 'options' => { 'filters' => filters } }, C4Task)

    filter = task.patient_cache_filter

    assert filter.count == 1 && filter['patients']
  end

  def record_has_payer?(record, payer)
    all_payers = record.insurance_providers.collect { |ip| ip.payer.name }
    all_payers.include? payer
  end

  def test_filter_problem
    filters = { 'problems' => ['2.16.840.1.113883.3.464.1003.101.12.1001', '2.16.840.1.113883.3.464.1003.101.12.1048'] }
    task = @product_test.tasks.create({ 'options' => { 'filters' => filters } }, C4Task)

    filter = task.patient_cache_filter
    assert filter.count == 1 && filter['patients']
  end

  def test_filter_npi
  end

  def test_filter_tin
  end

  def test_filter_prov_type
  end

  def test_filter_practice_site_addr
  end

  def validate_record_count(all_records, filtered_records, expected_count = -1)
    assert(all_records.count >= filtered_records.count, 'Filtered set of records is larger than original Unfiltered set')

    if expected_count > -1
      assert(expected_count == filtered_records.count, 'Filtered set of records does not match expected count')
    end
  end
end
