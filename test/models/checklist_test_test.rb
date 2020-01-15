require 'test_helper'

class ChecklistTestTest < ActiveJob::TestCase
  def setup
    @product = FactoryBot.create(:product_static_bundle)
    @test = @product.product_tests.create!({ name: 'c1 visual', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, ChecklistTest)
  end

  def test_create
    assert @test.valid?, 'product test should be valid with product, name, and measure_id'
    assert @test.checked_criteria? == false
    @test.create_checked_criteria
    assert @test.checked_criteria?
  end

  def test_attribute_index
    attributes1 = { 'dataElementAttributes' => [{ 'attribute_name' => 'relevantPeriod', 'attribute_valueset' => nil },
                                                { 'attribute_name' => 'dischargeDisposition', 'attribute_valueset' => '1.1.2.3' }] }
    attributes2 = { 'dataElementAttributes' => [{ 'attribute_name' => 'relevantPeriod', 'attribute_valueset' => nil },
                                                { 'attribute_name' => 'id', 'attribute_valueset' => nil }] }
    attributes3 = { 'dataElementAttributes' => [{ 'attribute_name' => 'relevantPeriod', 'attribute_valueset' => nil },
                                                { 'attribute_name' => 'dischargeDisposition', 'attribute_valueset' => nil },
                                                { 'attribute_name' => 'dischargeDisposition', 'attribute_valueset' => '1.1.2.3' }] }
    assert_equal 1, @test.attribute_index(attributes1), 'should return index for dischargeDisposition with a valueset oid'
    assert_equal 0, @test.attribute_index(attributes2), 'should return index for relevantPeriod'
    assert_equal 2, @test.attribute_index(attributes3), 'should return index for dischargeDisposition with a valueset oid'
  end

  def test_create_checked_criteria
    @test.create_checked_criteria
    assert @test.checked_criteria.count.positive?, 'should create checked criteria for one measure'
  end

  def test_create_checked_criteria_with_existing_measure_tests
    @product.c2_test = true
    @product.measure_ids << 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'
    @product.save!
    @product.measure_ids.each do |measure_id|
      # @product.product_tests.create!({ name: "measure test with measure id #{measure_id}", measure_ids: [measure_id] }, MeasureTest)
      @product.product_tests.build({ name: "measure test with measure id #{measure_id}", measure_ids: [measure_id] }, MeasureTest)
    end
    previous_num_checklist_measures = CAT1_CONFIG['number_of_checklist_measures']
    CAT1_CONFIG['number_of_checklist_measures'] = 1
    @test.create_checked_criteria
    CAT1_CONFIG['number_of_checklist_measures'] = previous_num_checklist_measures
    assert @test.checked_criteria.count.positive?, 'should create multiple checked criteria'
    assert_equal 1, @test.measures.count, 'should create checked criteria for one measure since number_of_checked_measures is set to 1'
  end

  def test_status
    @product.product_tests.each(&:destroy!)
    user = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')

    checklist_test = create_checklist_test_for_product_with_measure_id(@product, 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE')
    assert_equal 'incomplete', checklist_test.status
    simplify_criteria(checklist_test)
    checklist_test.checked_criteria << checklist_test.checked_criteria.first.clone
    # one complete checked criteria, all others incomplete
    complete_checked_criteria(checklist_test.checked_criteria.first)
    # puts @product.product_tests.first.rand_seed if checklist_test.status == 'passing'
    assert_equal 'incomplete', checklist_test.status

    # all complete checked criteria
    checklist_test.checked_criteria.each { |checked_criteria| complete_checked_criteria(checked_criteria) }
    assert_equal 'passing', checklist_test.status

    # add a c1 checklist task with test execution
    @product.update(c3_test: true)
    assert_equal 'incomplete', checklist_test.status
    task = checklist_test.tasks.create!({}, C1ChecklistTask)
    assert_equal 'incomplete', checklist_test.status
    task.test_executions.create(state: :pending, user: user)
    assert_equal 'incomplete', checklist_test.status
    task.test_executions.create(state: :passed, user: user)
    assert_equal 'passing', checklist_test.status
    task.test_executions.create(state: :failed, user: user)
    assert_equal 'failing', checklist_test.status
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
    measure_id = Measure.where(:hqmf_id.in => @test.measure_ids, :bundle_id => @test.product.bundle_id).first.id
    @test.create_checked_criteria
    assert_equal 'not_started', @test.measure_status(measure_id)
    @test.checked_criteria.first.code_complete = false
    @test.checked_criteria.first.code = '123'
    task = @test.tasks.create!({}, C1ChecklistTask)
    assert_equal 'incomplete', @test.measure_status(measure_id)
    user = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    task.test_executions.create(state: :failed, user: user)
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
    assert_not @test.checked_criteria[0].get_all_valuesets_for_dc(@test.measures.first.id).empty?, 'should be atleast one valuset for a data criteria'
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
    simplify_criteria(@test)
    checked_criteria = @test.checked_criteria[0]
    checked_criteria.attribute_code = 'thisalsoisntacode'
    checked_criteria.validate_criteria
    checked_criteria.save
    assert_equal false, checked_criteria.attribute_complete, 'attribute complete should be false when incorrect code is provided'
  end

  def test_appropriate_code_for_attribute_vs
    @test.create_checked_criteria
    simplify_criteria(@test)
    checked_criteria = @test.checked_criteria[0]
    checked_criteria.code = '720'
    checked_criteria.attribute_code = '210'
    checked_criteria.validate_criteria
    checked_criteria.save
    assert_equal true, checked_criteria.code_complete, 'code complete should be true when correct code is provided'
    assert_equal true, checked_criteria.attribute_complete, 'attribute complete should be true when correct code is provided'
  end

  def test_build_execution_errors_for_incomplete_checked_criteria
    user = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    @test.create_checked_criteria
    task = @test.tasks.create({}, C1ChecklistTask)

    execution = task.test_executions.build
    assert_equal 0, execution.execution_errors.count
    @test.build_execution_errors_for_incomplete_checked_criteria(execution)
    user.test_executions << execution
    execution.save!
    assert_equal @test.checked_criteria.count, execution.execution_errors.count

    simplify_criteria(@test, true)

    execution = task.test_executions.build
    assert_equal 0, execution.execution_errors.count
    @test.build_execution_errors_for_incomplete_checked_criteria(execution)
    user.test_executions << execution
    execution.save!
    assert_equal @test.checked_criteria.count - 1, execution.execution_errors.count, 'should have one less execution error'
  end

  def test_repeatability_with_random_seed
    # create new tests with same seed
    random = Random.new_seed
    test1 = @test.product.product_tests.create!({ name: 'test_for_measure_1a',
                                                  measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, ChecklistTest)
    test2 = @test.product.product_tests.create!({ name: 'test_for_measure_1a',
                                                  measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, ChecklistTest)

    test1.rand_seed = random
    test2.rand_seed = random
    test1.save!
    test2.save!
    assert_equal test1.rand_seed, test2.rand_seed

    test1.create_checked_criteria
    test2.create_checked_criteria

    compare_checklist_tests(test1, test2)
  end

  def compare_checklist_tests(test1, test2)
    # compare each checked criteria mongoid measure ids
    test1.checked_criteria.each_index do |x|
      assert_equal test1.checked_criteria.fetch(x).measure_id, test2.checked_criteria.fetch(x).measure_id, 'random repeatability error: checklist test checked criteria measure id not matched'
    end

    # compare each checked criteria source data criteria
    test1.checked_criteria.each_index do |x|
      assert_equal test1.checked_criteria.fetch(x).source_data_criteria, test2.checked_criteria.fetch(x).source_data_criteria, 'random repeatability error: checklist test checked criteria source data not matched'
    end

    # compare each official measure id
    test1.measure_ids.each_index do |x|
      assert_equal test1.measure_ids.fetch(x), test2.measure_ids.fetch(x), 'random repeatability error: checklist test measure id not matched'
    end
  end
end
