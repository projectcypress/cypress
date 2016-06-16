require 'test_helper'

class ChecklistTestTest < ActiveJob::TestCase
  def setup
    collection_fixtures('patient_cache', 'records', 'bundles', 'measures', 'health_data_standards_svs_value_sets')
    vendor = Vendor.create!(name: 'test_vendor_name')
    product = vendor.products.create!(name: 'test_product', c1_test: true, bundle_id: '4fdb62e01d41c820f6000001',
                                      measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'])
    @test = product.product_tests.create!({ name: 'test_for_measure_1a',
                                            measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'] }, ChecklistTest)
  end

  def test_create
    assert_enqueued_jobs 0
    assert @test.valid?, 'product test should be valid with product, name, and measure_id'
    assert @test.checked_criteria? == false
    @test.create_checked_criteria
    assert @test.checked_criteria?
  end

  def test_create_checked_criteria
    @test.create_checked_criteria
    assert @test.checked_criteria.count > 0, 'should create checked criteria for one measure'
  end

  def test_num_measures_complete_and_num_measures_not_started
    assert_equal 0, @test.num_measures_complete
    assert_equal 1, @test.num_measures_not_started
    @test.create_checked_criteria
    @test.checked_criteria.each do |criteria|
      criteria.code_complete = true
      criteria.code = '123'
    end
    assert_equal 1, @test.num_measures_complete
    assert_equal 0, @test.num_measures_not_started
  end

  def test_measure_status
    measure_id = Measure.top_level.where(:hqmf_id.in => @test.measure_ids).first.id
    @test.create_checked_criteria
    assert_equal 'not_started', @test.measure_status(measure_id)
    @test.checked_criteria.first.code_complete = false
    @test.checked_criteria.first.code = '123'
    assert_equal 'failed', @test.measure_status(measure_id)
    @test.checked_criteria.each do |criteria|
      criteria.code_complete = true
      criteria.code = '123'
    end
    assert_equal 'passed', @test.measure_status(measure_id)
  end

  def test_get_valuesets_for_dc
    @test.create_checked_criteria
    assert !@test.checked_criteria[0].get_all_valuesets_for_dc(@test.measures.first.id).empty?, 'should be atleast one valuset for a data criteria'
  end

  def test_inappropriate_code_for_vs
    @test.create_checked_criteria
    checked_criteria = @test.checked_criteria[0]
    checked_criteria.code = 'thisisntacode'
    checked_criteria.validate_criteria
    checked_criteria.save
    assert_equal false, checked_criteria.code_complete, 'code complete should be false when incorrect code is provided'
  end

  def test_inappropriate_code_for_attribute_vs
    @test.create_checked_criteria
    checked_criteria = @test.checked_criteria[0]
    checked_criteria.attribute_code = 'thisalsoisntacode'
    checked_criteria.validate_criteria
    checked_criteria.save
    assert_equal false, checked_criteria.attribute_complete, 'attribute complete should be false when incorrect code is provided'
  end

  def test_appropriate_code_for_attribute_vs
    @test.create_checked_criteria
    checked_criteria = @test.checked_criteria[0]
    checked_criteria.code = 'F32.9'
    checked_criteria.attribute_code = '63161005'
    checked_criteria.validate_criteria
    checked_criteria.save
    assert_equal true, checked_criteria.code_complete, 'code complete should be true when correct code is provided'
    assert_equal true, checked_criteria.attribute_complete, 'attribute complete should be true when correct code is provided'
  end
end
