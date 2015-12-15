module ProductsHelper
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
    status_list = status_list.map(&:status)

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
      product_certifications[k] = CERTIFICATIONS[k] if v
    end
    product_certifications
  end
end
