require 'test_helper'

class ChecklistTestTest < ActiveJob::TestCase
  def setup
    collection_fixtures('patient_cache', 'records', 'bundles', 'measures')
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
    @test.checked_criteria.each { |criteria| criteria.completed = true }
    assert_equal 1, @test.num_measures_complete
    assert_equal 0, @test.num_measures_not_started
  end

  def test_measure_status
    measure_id = Measure.top_level.where(:hqmf_id.in => @test.measure_ids).first.id
    @test.create_checked_criteria
    assert_equal 'not_started', @test.measure_status(measure_id)
    @test.checked_criteria.first.completed = true
    assert_equal 'failed', @test.measure_status(measure_id)
    @test.checked_criteria.each { |criteria| criteria.completed = true }
    assert_equal 'passed', @test.measure_status(measure_id)
  end
end
