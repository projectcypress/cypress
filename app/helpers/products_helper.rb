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

  # task_type can only be 'C1Task' or 'C2Task'
  #   this is because the c3 test executions are only available through their sibling c1 or c2 test execution
  def measure_test_status_values(tests, task_type, is_c3)
    tasks = []
    tests.each { |test| tasks << test.tasks.where(_type: task_type) }
    if tasks.empty?
      [0, 0, 0, 0]
    else
      is_c3 ? c3_tasks_values(tasks) : tasks_values(tasks)
    end
  end

<<<<<<< HEAD
  def tasks_values(tasks)
    status_values = []
    %w(passing failing incomplete).each { |status| status_values << tasks.count { |task| task.first.status == status } }
    status_values << tasks.count
=======
  def filtering_test_status_values(_tests)
    passing = failing = not_started = total = 0

    # add content here when C4 tasks are finalized

    [passing, failing, not_started, total]
>>>>>>> implmenting inital roles authorization in controllers
  end

  def c3_tasks_values(tasks)
    status_values = []
    %w(passing failing incomplete).each { |status| status_values << tasks.count { |task| task.first.c3_status == status } }
    status_values << tasks.count
  end

  def filtering_test_status_values(tests, task_type)
    tasks = []
    tests.each { |test| tasks << test.tasks.where(_type: task_type) }
    tasks.empty? ? [0, 0, 0, 0] : tasks_values(tasks)
  end

  def filtering_test_status_values_summed(tests)
    cat1 = filtering_test_status_values(tests, 'Cat1FilterTask')
    cat3 = filtering_test_status_values(tests, 'Cat3FilterTask')
    cat1.map.with_index { |cat1_elem, i| cat1_elem + cat3[i] }
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

  def generate_filter_records(filter_tests)
    return unless filter_tests
    test = filter_tests.pop
    test.generate_records
    test.save
    ProductTestSetupJob.perform_later(test)
    records = test.records
    filter_tests.each do |ft|
      records.collect do |r|
        r2 = r.clone
        r2.test_id = ft.id
        r2.save
        r2
      end
      ft.save
      ProductTestSetupJob.perform_later(ft)
    end
  end
end
