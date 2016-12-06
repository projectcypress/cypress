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

  def test_create_checked_criteria_with_existing_measure_tests
    product = @test.product
    product.c2_test = true
    product.measure_ids << '8A4D92B2-397A-48D2-0139-C648B33D5582'
    product.save!
    product.measure_ids.each do |measure_id|
      product.product_tests.create!({ name: "measure test with measure id #{measure_id}", measure_ids: [measure_id] }, MeasureTest)
    end

    CAT1_CONFIG['number_of_checklist_measures'] = 1
    @test.create_checked_criteria
    assert @test.checked_criteria.count > 0, 'should create multiple checked criteria'
    assert_equal 1, @test.measures.count, 'should create checked criteria for one measure since number_of_checked_measures is set to 1'
  end

  def test_create_checked_criteria_without_existing_measure_tests
    product = @test.product
    product.c2_test = false
    product.measure_ids << '40280381-4BE2-53B3-014C-0F589C1A1C39'
    product.save!
    product.product_tests.measure_tests.each(&:destroy)
    @test.measure_ids = product.measure_ids

    CAT1_CONFIG['number_of_checklist_measures'] = 1
    @test.create_checked_criteria
    assert @test.checked_criteria.count > 0, 'should create multiple checked criteria'
    assert_equal product.measure_ids.count, @test.measures.count, 'should create checked criteria for all measures since'
  end

  def test_status
    # all incomplete checked criteria
    product = @test.product
    product.product_tests.each(&:destroy)
    checklist_test = create_checklist_test_for_product_with_measure_id(product, '40280381-4BE2-53B3-014C-0F589C1A1C39')
    assert_equal 'incomplete', checklist_test.status

    # one complete checked criteria, all others incomplete
    complete_checked_criteria(checklist_test.checked_criteria.first)
    assert_equal 'incomplete', checklist_test.status

    # all complete checked criteria
    checklist_test.checked_criteria.each { |checked_criteria| complete_checked_criteria(checked_criteria) }
    assert_equal 'passing', checklist_test.status

    # add a c1 manual task with test execution
    product.c3_test = true
    product.save!
    assert_equal 'incomplete', checklist_test.status
    task = checklist_test.tasks.create!({}, C1ManualTask)
    assert_equal 'incomplete', checklist_test.status
    task.test_executions.create!(:state => :pending)
    assert_equal 'incomplete', checklist_test.status
    task.test_executions.create!(:state => :passed)
    assert_equal 'passing', checklist_test.status
  end

  def create_checklist_test_for_product_with_measure_id(product, measure_id)
    checklist_test = product.product_tests.build({ name: "my product test for measure id #{measure_id}", measure_ids: [measure_id] }, ChecklistTest)
    checklist_test.save!
    checklist_test.create_checked_criteria
    checklist_test
  end

  def complete_checked_criteria(checked_criteria)
    random_number = rand
    checked_criteria.code = "my code #{random_number}"
    checked_criteria.attribute_code = "my attribute code #{random_number}"
    checked_criteria.recorded_result = "my recorded result #{random_number}"
    checked_criteria.code_complete = true
    checked_criteria.attribute_complete = true
    checked_criteria.result_complete = true
    checked_criteria.passed_qrda = true
  end

  def test_num_measures_complete_and_num_measures_not_started
    assert_equal 0, @test.num_measures_complete
    assert_equal 1, @test.num_measures_not_started
    @test.create_checked_criteria
    @test.checked_criteria.each do |criteria|
      criteria.code_complete = true
      criteria.code = '123'
      criteria.passed_qrda = true
    end
    assert_equal 1, @test.num_measures_complete
    assert_equal 0, @test.num_measures_not_started
  end

  def test_measure_status
    measure_id = Measure.top_level.where(:hqmf_id.in => @test.measure_ids, :bundle_id => @test.product.bundle_id).first.id
    @test.create_checked_criteria
    assert_equal 'not_started', @test.measure_status(measure_id)
    @test.checked_criteria.first.code_complete = false
    @test.checked_criteria.first.code = '123'
    assert_equal 'failed', @test.measure_status(measure_id)
    @test.checked_criteria.each do |criteria|
      criteria.code_complete = true
      criteria.code = '123'
      criteria.passed_qrda = true
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

  def test_build_execution_errors_for_incomplete_checked_criteria
    @test.create_checked_criteria
    task = @test.tasks.create({}, C1ManualTask)

    execution = task.test_executions.build
    assert_equal 0, execution.execution_errors.count
    @test.build_execution_errors_for_incomplete_checked_criteria(execution)
    execution.save!
    assert_equal @test.checked_criteria.count, execution.execution_errors.count

    # make one checked criteria complete
    simplify_criteria(@test)

    execution = task.test_executions.build
    assert_equal 0, execution.execution_errors.count
    @test.build_execution_errors_for_incomplete_checked_criteria(execution)
    execution.save!
    assert_equal @test.checked_criteria.count - 1, execution.execution_errors.count, 'should have one less execution error'
  end

  def simplify_criteria(test)
    criterias = test.checked_criteria
    criterias[0].source_data_criteria = 'DiagnosisActiveMajorDepressionIncludingRemission_precondition_40'
    criterias[0].code = '14183003'
    criterias[0].code_complete = true
    criterias[0].attribute_code = '63161005'
    criterias[0].attribute_complete = true
    criterias[0].result_complete = true
    criterias[0].passed_qrda = true
    test.checked_criteria = criterias
    test.save!
  end

  def test_repeatability_with_random_seed
    # create new tests with same seed
    random = Random.new_seed
    test_1 = @test.product.product_tests.create!({ name: 'test_for_measure_1a',
                                                   measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'] }, ChecklistTest)
    test_2 = @test.product.product_tests.create!({ name: 'test_for_measure_1a',
                                                   measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'] }, ChecklistTest)

    test_1.rand_seed = random
    test_2.rand_seed = random
    test_1.save!
    test_2.save!
    assert_equal test_1.rand_seed, test_2.rand_seed

    test_1.create_checked_criteria
    test_2.create_checked_criteria

    compare_checklist_tests(test_1, test_2)
  end

  def compare_checklist_tests(test_1, test_2)
    # compare each checked criteria mongoid measure ids
    test_1.checked_criteria.each_index do |x|
      assert_equal test_1.checked_criteria.fetch(x).measure_id, test_2.checked_criteria.fetch(x).measure_id, 'random repeatability error: checklist test checked criteria measure id not matched'
    end

    # compare each checked criteria source data criteria
    test_1.checked_criteria.each_index do |x|
      assert_equal test_1.checked_criteria.fetch(x).source_data_criteria, test_2.checked_criteria.fetch(x).source_data_criteria, 'random repeatability error: checklist test checked criteria source data not matched'
    end

    # compare each official measure id
    test_1.measure_ids.each_index do |x|
      assert_equal test_1.measure_ids.fetch(x), test_2.measure_ids.fetch(x), 'random repeatability error: checklist test measure id not matched'
    end
  end
end
