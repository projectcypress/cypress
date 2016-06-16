module ProductsHelper
  # used in product create
  def measure_checkbox_attributes(measure, category, selected_measure_ids)
    {
      :class => 'measure-checkbox',
      :id => "product_measure_ids_#{measure.hqmf_id}",
      :multiple => true,
      :checked => selected_measure_ids && selected_measure_ids.include?(measure.hqmf_id),
      'data-category' => category.tr(" '", '_'),
      'data-measure-type' => measure.type,
      'data-parsley-mincheck' => '1',
      'data-parsley-required' => '',
      'data-parsley-multiple' => 'multiple_measure_checkboxes',
      'data-parsley-error-message' => 'Must select measures',
      'data-parsley-errors-container' => '#measures_errors_container',
      'aria-labelledby' => 'select_custom_measures'
    }
  end

  def measure_checkbox_should_be_skipped?(product_test_form, product_tests, cur_measure, first_iteration)
    return !first_iteration unless product_tests.any? { |test| test['measure_ids'] && test.measure_ids.first == cur_measure.hqmf_id }
    product_test_form.object.measure_ids.first != cur_measure.hqmf_id
  end

  # returns zero for all values if test is false
  def checklist_status_values(test)
    return [0, 0, 0, 0] unless test
    passing = test.num_measures_complete
    total = test.measures.count
    not_started = test.num_measures_not_started
    failing = total - not_started - passing
    [passing, failing, not_started, total]
  end

  def product_test_statuses(tests, task_type)
    tasks = []
    tests.each { |test| tasks << test.tasks.where(_type: task_type) }
    tasks.empty? ? [0, 0, 0, 0] : tasks_values(tasks)
  end

  def tasks_values(tasks)
    status_values = []
    %w(passing failing incomplete).each { |status| status_values << tasks.count { |task| task.first.status == status } }
    status_values << tasks.count # total number of product tests
  end

  def certifications(product)
    # Get a hash of certification types for this product
    certs = {
      'C1' => product.c1_test, 'C2' => product.c2_test,
      'C3' => product.c3_test, 'C4' => product.c4_test
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

  def type_counts(measures)
    h = measures.map(&:type).each_with_object(Hash.new(0)) { |type, count| count[type.upcase] += 1 } # example { "EH"=> 4, "EP" => 2 }
    h.map { |k, v| "#{v} #{k}" }.join(', ') # 4 EH, 2 EP
  end

  def set_sorting(test, test_status)
    return 1 if test.state == :queued
    return 2 if test.state == :building

    case test_status
    when 'passing'
      return 5
    when 'failing'
      return 4
    when 'incomplete'
      return 3
    else
      return 6
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
    records.any? ? records.sort_by { |r| r[:new_name] }.uniq : records
  end
end
