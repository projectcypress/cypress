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

  def product_test_status_values(tests, task_type)
    tasks = []
    tests.each { |test| tasks << test.tasks.where(_type: task_type) }
    tasks.empty? ? [0, 0, 0, 0] : tasks_values(tasks)
  end

  def tasks_values(tasks)
    status_values = []
    %w(passing failing incomplete).each { |status| status_values << tasks.count { |task| task.first.status == status } }
    status_values << tasks.count # total number of product tests
  end

  def filtering_test_status_values_summed(tests)
    cat1 = product_test_status_values(tests, 'Cat1FilterTask')
    cat3 = product_test_status_values(tests, 'Cat3FilterTask')
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
    test.queued
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
      ft.queued
      ProductTestSetupJob.perform_later(ft)
    end
  end

  # For pdf
  def all_records_for_product(product)
    records = []
    product.product_tests.each do |pt|
      pt.records.each do |r|
        new_name = "#{r.first} #{r.last}"
        original_patient = r.bundle.records.find_by(medical_record_number: r.original_medical_record_number)
        original_name = "#{original_patient.first} #{original_patient.last}"
        records << { new_name: new_name, original: original_name }
      end
    end

    records.any? ? records.sort_by! { |r| r[:new_name] }.uniq! : records
  end
end
