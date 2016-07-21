module Cypress
  module ProductStatusValues
    def c1_status_values(product)
      h = {}
      h['Manual'] = Hash[%w(passing failing errored not_started total).zip(manual_status_valss(product.product_tests.checklist_tests.first, 'C1'))]
      if h['Manual']['total'] == 0
        default_number = CAT1_CONFIG['number_of_checklist_measures']
        h['Manual']['not_started'] = product.measure_ids.size < default_number ? product.measure_ids.size : default_number
      end
      h['QRDA Category I'] = Hash[%w(passing failing errored not_started total).zip(product_test_statuses(product.product_tests.measure_tests,
                                                                                                          'C1Task'))]
      h
    end

    def c2_status_values(product)
      h = {}
      h['QRDA Category III'] = Hash[%w(passing failing errored not_started total).zip(product_test_statuses(product.product_tests.measure_tests,
                                                                                                            'C2Task'))]
      h
    end

    def c3_status_values(product)
      h = {}
      h['Manual'] = Hash[%w(passing failing errored not_started total).zip(manual_status_vals(product.product_tests.checklist_tests.first, 'C3'))]
      if h['Manual']['total'] == 0
        default_number = CAT1_CONFIG['number_of_checklist_measures']
        h['Manual']['not_started'] = product.measure_ids.size < default_number ? product.measure_ids.size : default_number
      end
      cat1_status_values = product.c1_test ? product_test_statuses(product.product_tests.measure_tests, 'C3Cat1Task') : [0, 0, 0, 0, 0]
      cat3_status_values = product.c2_test ? product_test_statuses(product.product_tests.measure_tests, 'C3Cat3Task') : [0, 0, 0, 0, 0]
      h['QRDA Category I'] = Hash[%w(passing failing errored not_started total).zip(cat1_status_values)]
      h['QRDA Category III'] = Hash[%w(passing failing errored not_started total).zip(cat3_status_values)]
      h
    end

    def c4_status_values(filtering_tests)
      h = {}
      h['QRDA Category I'] = Hash[%w(passing failing errored not_started total).zip(product_test_statuses(filtering_tests, 'Cat1FilterTask'))]
      h['QRDA Category III'] = Hash[%w(passing failing errored not_started total).zip(product_test_statuses(filtering_tests, 'Cat3FilterTask'))]
      h
    end

    # returns zero for all values if test is false
    def manual_status_vals(test, cert_type)
      return [0, 0, 0, 0, 0] unless test
      passing = test.num_measures_complete
      total = test.measures.count
      not_started = test.num_measures_not_started
      failing = total - not_started - passing
      [passing, failing, 0, not_started, total].zip(manual_status_vals_for_execution(test, cert_type)).map { |x, y| x + y } # sums elements of arrays
    end

    # returns the number of tasks with most recent test executions [passing, failing, errored, not_started, total]
    def manual_status_vals_for_execution(test, cert_type)
      task = (cert_type == 'C3') ? test.tasks.c3_manual_task : test.tasks.c1_manual_task
      return [0, 0, 0, 0, 0] unless task && task.most_recent_execution
      case task.most_recent_execution.status_with_sibling
      when 'passing' then [1, 0, 0, 0, 1]
      when 'failing' then [0, 1, 0, 0, 1]
      when 'errored' then [0, 0, 1, 0, 1]
      else [0, 0, 0, 1, 1]
      end
    end

    def product_test_statuses(tests, task_type)
      tasks = []
      tests.each { |test| tasks << test.tasks.where(_type: task_type) }
      tasks.empty? ? [0, 0, 0, 0, 0] : tasks_values(tasks)
    end

    def tasks_values(tasks)
      status_values = []
      %w(passing failing errored incomplete).each { |status| status_values << tasks.count { |task| task.first.status == status } }
      status_values << tasks.count # total number of product tests
    end
  end
end
