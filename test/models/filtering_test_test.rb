require 'test_helper'

class FilteringTestTest < ActiveJob::TestCase
  def setup
    @product = FactoryBot.create(:product_static_bundle)
  end

  def test_create
    assert_enqueued_jobs 1
    options = { 'filters' => {} }
    ft = @product.product_tests.build({ name: 'test_for_measure_1a',
                                        measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                                        options: options }, FilteringTest)

    assert ft.valid?
  end

  def test_pick_filter_criteria
    criteria = %w[races ethnicities genders payers providers problems age]
    options = { 'filters' => Hash[criteria.map { |c| [c, []] }] }
    ft = FilteringTest.new(name: 'test_for_measure_1a', product: @product, incl_addr: true, options: options,
                           measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    ft.save!
    ft.generate_patients
    ft.reload
    ft.pick_filter_criteria
    options_assertions(ft)
  end

  def test_problem_filter
    criteria = %w[problems]
    options = { 'filters' => Hash[criteria.map { |c| [c, []] }] }
    ft = FilteringTest.new(name: 'test_for_measure_1a', product: @product, incl_addr: true, options: options,
                           measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    ft.save!
    ft.generate_patients
    ft.reload
    ft.pick_filter_criteria
    # There should be at least one record that meets the problem filter
    assert_not ft.filtered_records.empty?
  end

  def options_assertions(filter_test)
    assert_equal 1, filter_test.options['filters']['races'].count
    assert_equal 1, filter_test.options['filters']['ethnicities'].count
    assert filter_test.options['filters']['genders'].count
    assert_equal 1, filter_test.options['filters']['payers'].count
    providers_assertions(filter_test)
    assert_equal 1, filter_test.options['filters']['problems']['oid'].count
  end

  def age_assertions(filter_test)
    age_filter = filter_test.options['filters']['age']
    assert_equal 1, age_filter.count == 1
    assert age_filter[:min] || age_filter[:max]
    assert age_filter[:min].positive? if age_filter[:min]
  end

  def providers_assertions(filter_test)
    assert filter_test.options['filters']['providers']['npis']
    assert filter_test.options['filters']['providers']['tins']
    assert filter_test.options['filters']['providers']['addresses']
  end

  def test_task_status_with_existing_tasks
    # valid filter test should call create_tasks after filter test is created
    test = @product.product_tests.create!({ name: 'test_for_measure_1a',
                                            measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                                            options: { 'filters' => {} } }, FilteringTest)
    test.tasks.find_by(_type: 'Cat1FilterTask').test_executions.build(:state => :passed).save!

    assert_equal 'passing', test.task_status('Cat1FilterTask')
    assert_equal 'incomplete', test.task_status('Cat3FilterTask')
  end

  def test_task_status_with_non_existant_tasks
    test = @product.product_tests.create({}, FilteringTest)
    assert_equal 'incomplete', test.task_status('Cat1FilterTask')
    assert_equal 'incomplete', test.task_status('Cat3FilterTask')
  end

  def test_cat1_and_cat3_tasks
    test = @product.product_tests.create({}, FilteringTest)
    assert_not test.cat1_task
    assert_not test.cat3_task

    test.create_tasks
    assert test.cat1_task
    assert test.cat3_task
  end

  def test_repeatability_with_random_seed
    # create new tests with same seed
    seed = Random.new_seed
    options = { 'filters' => {} }
    test1 = @product.product_tests.build({ :name => 'test_for_measure_1a',
                                           :measure_ids => ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                                           :options => options }, FilteringTest)
    test2 = @product.product_tests.build({ :name => 'test_for_measure_1a',
                                           :measure_ids => ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                                           :options => options }, FilteringTest)
    test1.save!
    test2.save!

    test1.rand_seed = seed
    test2.rand_seed = seed
    test1.save!
    test2.save!
    assert_equal test1.rand_seed, test2.rand_seed, 'random repeatability error: random seeds don\'t match'

    # create tasks and test equivalence of randomized components
    test1.create_tasks
    test2.create_tasks

    test1.options['filters'].each do |k, _v|
      assert_equal test1.options['filters'][k], test2.options['filters'][k], 'random repeatability error: filtering test filters do not match'
    end
  end
end
