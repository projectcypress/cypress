require 'test_helper'
require 'fileutils'

# rubocop:disable Metrics/ClassLength

class RecordFilterTest < ActiveSupport::TestCase
  def setup
    drop_database
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')

    @all_records = Record.all
  end

  def after_teardown
    # drop_database
  end

  def test_filter_gender
    selected_gender = %w(M F).sample
    filters = { 'genders' => [selected_gender] }

    filtered_records = Cypress::RecordFilter.filter(@all_records, filters, {}).to_a

    @all_records.each do |r|
      if filtered_records.include? r
        assert(r.gender == selected_gender, 'Filtered record set includes a record that does not match criteria')
      else
        assert(r.gender != selected_gender, 'Filtered record set does not include a record that matches criteria')
      end
    end
  end

  def test_filter_race
    selected_race = %w(2106-3 2028-9 2054-5).sample
    filters = { 'races' => [selected_race] }

    filtered_records = Cypress::RecordFilter.filter(@all_records, filters, {}).to_a

    @all_records.each do |r|
      if filtered_records.include? r
        assert(r.race['code'] == selected_race, 'Filtered record set includes a record that does not match criteria')
      else
        assert(r.race['code'] != selected_race, 'Filtered record set does not include a record that matches criteria')
      end
    end
  end

  def test_filter_ethnicity
    selected_ethn = %w(2186-5 2135-2).sample

    filters = { 'ethnicities' => [selected_ethn] }

    filtered_records = Cypress::RecordFilter.filter(@all_records, filters, {}).to_a

    @all_records.each do |r|
      if filtered_records.include? r
        assert(r.ethnicity['code'] == selected_ethn, 'Filtered record set includes a record that does not match criteria')
      else
        assert(r.ethnicity['code'] != selected_ethn, 'Filtered record set does not include a record that matches criteria')
      end
    end
  end

  def test_filter_age_max
    ## reminder: for dates, > means later/younger...
    now = Time.now.utc

    target_age = Random.rand(100)

    filters = { 'age' => { 'max' => target_age } }

    filtered_records = Cypress::RecordFilter.filter(@all_records, filters, effective_date: now.to_i).to_a

    validate_record_count(@all_records, filtered_records)

    @all_records.each do |r|
      dob = Time.at(r.birthdate).utc
      patient_age = age_on_date(dob, now)

      if filtered_records.include? r
        assert(patient_age <= target_age, 'Filtered record set includes a record that does not match criteria')
      else
        assert(patient_age > target_age, 'Filtered record set does not include a record that matches criteria')
      end
    end
  end

  def test_filter_age_min
    ## reminder: for dates, > means later/younger...
    now = Time.now.utc

    target_age = Random.rand(100)

    filters = { 'age' => { 'min' => target_age } }

    filtered_records = Cypress::RecordFilter.filter(@all_records, filters, effective_date: now.to_i).to_a

    validate_record_count(@all_records, filtered_records)

    @all_records.each do |r|
      dob = Time.at(r.birthdate).utc
      patient_age = age_on_date(dob, now)

      if filtered_records.include? r
        assert(patient_age >= target_age, 'Filtered record set includes a record that does not match criteria')
      else
        assert(patient_age < target_age, 'Filtered record set does not include a record that matches criteria')
      end
    end
  end

  def test_filter_age_edge_case_inclusive
    # the "edge case" for age filtering is when the patient's birthdate is on the effective date

    patient = @all_records.sample
    birthdate = Time.at(patient.birthdate).utc

    # CASE 1
    age = Random.rand(100)
    effective_date = Time.utc(birthdate.year + age, birthdate.month, birthdate.day, 0, 0, 0)

    filters = { 'age' => { 'min' => age } }
    filtered_records = Cypress::RecordFilter.filter(@all_records, filters, effective_date: effective_date).to_a

    assert filtered_records.include? patient

    # CASE 2
    age = Random.rand(100)
    effective_date = Time.utc(birthdate.year + age, birthdate.month, birthdate.day, 0, 0, 0)

    filters = { 'age' => { 'max' => age } }
    filtered_records = Cypress::RecordFilter.filter(@all_records, filters, effective_date: effective_date).to_a

    assert filtered_records.include? patient
  end

  def test_filter_age_edge_case_exclusive
    patient = @all_records.sample
    birthdate = Time.at(patient.birthdate).utc

    # CASE 1
    age = Random.rand(100)
    effective_date = Time.utc(birthdate.year + age, birthdate.month, birthdate.day, 0, 0, 0)

    filters = { 'age' => { 'min' => age + 1 } }
    filtered_records = Cypress::RecordFilter.filter(@all_records, filters, effective_date: effective_date).to_a

    assert !filtered_records.include?(patient)

    # CASE 2
    age = Random.rand(100)
    effective_date = Time.utc(birthdate.year + age, birthdate.month, birthdate.day, 0, 0, 0)

    filters = { 'age' => { 'max' => age - 1 } }
    filtered_records = Cypress::RecordFilter.filter(@all_records, filters, effective_date: effective_date).to_a

    assert !filtered_records.include?(patient)
  end

  # helper function to calculate age
  def age_on_date(dob, now)
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def test_filter_payer
    selected_payer = %w('Medicaid Medicare Other).sample
    filters = { 'payers' => [selected_payer] }

    filtered_records = Cypress::RecordFilter.filter(@all_records, filters, {}).to_a

    @all_records.each do |r|
      if filtered_records.include? r
        assert(record_has_payer?(r, selected_payer), 'Filtered record set includes a record that does not match criteria')
      else
        assert(!record_has_payer?(r, selected_payer), 'Filtered record set does not include a record that matches criteria')
      end
    end
  end

  def record_has_payer?(record, payer)
    all_payers = record.insurance_providers.collect { |ip| ip.payer.name }
    all_payers.include? payer
  end

  def test_filter_problem
    selected_problem = %w(2.16.840.1.113883.3.464.1003.101.12.1001 2.16.840.1.113883.3.464.1003.101.12.1048).sample

    filters = { 'problems' => [selected_problem] }

    filtered_records = Cypress::RecordFilter.filter(@all_records, filters, {}).to_a

    code_sets = HealthDataStandards::SVS::ValueSet.where('oid' => selected_problem).pluck('concepts')

    relevant_codes = []

    code_sets.each do |code_set|
      code_set.each do |code|
        # problems come from SNOMED, per the rule
        relevant_codes << code['code'] if code['code_system'] == '2.16.840.1.113883.6.96'
      end
    end

    relevant_codes.uniq!

    @all_records.each do |r|
      if filtered_records.include? r
        assert(record_has_problem?(r, relevant_codes), 'Filtered record set includes a record that does not match criteria')
      else
        assert(!record_has_problem?(r, relevant_codes), 'Filtered record set does not include a record that matches criteria')
      end
    end
  end

  def record_has_problem?(record, code_set)
    search_fields = [record.conditions, record.encounters, record.procedures]

    search_fields.each do |search_field|
      next unless search_field
      search_field.each do |item|
        if item.codes && item.codes['SNOMED-CT'] && (item.codes['SNOMED-CT'] & code_set) != []
          return true
        end
      end
    end

    false
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
