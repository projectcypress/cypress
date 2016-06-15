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

  # input tasks should be array of (c1 or c2 task) and (c3 task if c3 was selected on product)
  # true if the task's product test is still building or if there is a test execution currently running
  def should_reload_product_test_link?(tasks)
    return true if tasks.first.product_test.state != :ready
    return true if tasks.any? { |task| task.most_recent_execution && task.most_recent_execution.state == :pending }
    false
  end

  # returns the status of the combined tasks for a product test
  #   all tasks must pass to return 'passing'
  #   if one test fails, return 'failing'
  def tasks_status(tasks)
    return tasks.first.status if tasks.count == 0
    return 'passing' if tasks.all?(&:passing?)
    return 'failing' if tasks.any?(&:failing?)
    return 'incomplete' if tasks.any?(&:incomplete?)
    'unstarted'
  end

  def id_for_html_wrapper_of_task(task)
    "wrapper-task-id-#{task.id.to_s}"
  end

  # returns array of tasks. includes a c3 task if it exists
  # input should be a c1 or c2 task
  def with_c3_task(task)
    return [task] unless task.product_test.product.c3_test
    case task._type
    when 'C1Task'
      return [task, task.product_test.tasks.c3_cat1_task]
    when 'C2Task'
      return [task, task.product_test.tasks.c3_cat3_task]
    end
    [task]
  end
end
