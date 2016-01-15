module ProductsHelper
  # returns zero for all values if test is false
  def checklist_status_values(test)
    passing = failing = total = 0
    return [passing, failing, total] unless test
    passing = test.num_measures_complete
    total = test.num_measures
    failing = total - passing
    [passing, failing, total]
  end

  def measure_test_status_values(tests, task_type)
    passing = failing = not_started = total = 0
    tasks = []
    tests.each { |test| tasks << test.tasks.where(_type: task_type) }
    unless tasks.empty?
      passing = tasks.count { |task| task.first.status == 'passing' }
      failing = tasks.count { |task| task.first.status == 'failing' }
      not_started = tasks.count { |task| task.first.status == 'incomplete' }
      total = tasks.count
    end
    [passing, failing, not_started, total]
  end

  def filtering_test_status_values(tests)
    passing = failing = not_started = total = 0

    # add content here when C4 tasks are finalized

    [passing, failing, not_started, total]
  end

  def filtering_test_statuses(test)
    [test.task_status('cat_1_filter_task'), test.task_status('cat_3_filter_task')]
  end

  def status_from_tasks(tests_type, task_type)
    # tests_type can be a set of product tests
    # task_type is a string representing the task type e.g. "C1Task"

    return 'incomplete' if tests_type.empty?
    # get the statuses of all tasks in a set of product tests
    if tests_type.first._type == 'FilteringTest' || tests_type.first._type == 'ChecklistTest'
      status_list = tests_type.first.tasks
    else
      status_list = tests_type.map do |test|
        t = test.tasks.where(_type: task_type)
        t.first
      end
    end

    status_list = status_list.reject(&:blank?).map(&:status) if status_list.any?

    overall_status(status_list)
  end

  def overall_status(status_list)
    # status_list is an array of strings

    if status_list.grep('failing').size > 0
      return 'failing'
    elsif status_list.grep('passing').size == status_list.size && status_list.size > 0
      return 'passing'
    else
      return 'incomplete'
    end
  end

  def status_by_test(product)
    # return a hash of results for each certification + test type
    statuses = {
      'MeasureTest' => {},
      'FilteringTest' => {},
      'ChecklistTest' => {}
    }

    if product.product_tests.measure_tests
      statuses['MeasureTest']['C1'] = status_from_tasks(product.product_tests.measure_tests, 'C1Task')
      statuses['MeasureTest']['C2'] = status_from_tasks(product.product_tests.measure_tests, 'C2Task')
      statuses['MeasureTest']['C3'] = status_from_tasks(product.product_tests.measure_tests, 'C3Task')
    end

    statuses['FilteringTest']['C4'] = status_from_tasks(product.product_tests.filtering_tests, 'C4Task') if product.product_tests.filtering_tests
    statuses['ChecklistTest']['C1'] = status_from_tasks(product.product_tests.checklist_tests, 'C1Task') if product.product_tests.checklist_tests

    statuses
  end

  def certifications(product)
    # Get a hash of certification types for this product
    certs = {
      'C1' => product.c1_test,
      'C2' => product.c2_test,
      'C3' => product.c3_test,
      'C4' => product.c4_test
    }

    product_certifications = {}

    certs.each do |k, v|
      product_certifications[k] = APP_CONFIG.certifications[k] if v
    end
    product_certifications
  end

  def product_certifying_to(product, certification_test)
    (certification_test['certifications'] & certifications(product).keys) != []
  end
end
