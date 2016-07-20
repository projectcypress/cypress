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

  def should_show_product_tests_tab?(product, test_type)
    case test_type
    when 'MeasureTest'
      return product.product_tests.measure_tests.any?
    when 'FilteringTest'
      return product.product_tests.filtering_tests.any?
    when 'ChecklistTest'
      return product.c1_test # should not check for existance of checklist test since there a user can delete checklist tests
    else
      return product.product_tests.any?
    end
  end

  def perform_c3_certification_during_measure_test_message(product, test_type)
    return '' unless test_type == 'MeasureTest' && product.c3_test
    certifications = [product.c1_test ? 'C1' : nil, product.c2_test ? 'C2' : nil].compact.join(' and ')
    " C3 certifications will automatically be performed during #{certifications} certifications."
  end

  def set_sorting(test, test_status)
    return 1 if test.state == :queued
    return 2 if test.state == :building

    case test_status
    when 'passing'
      return 6
    when 'failing'
      return 5
    when 'errored'
      return 4
    when 'incomplete'
      return 3
    else
      return 7
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

  def should_reload_measure_test_row?(task)
    return true if task.product_test.state != :ready
    executions = [task.most_recent_execution]
    executions << task.most_recent_execution.sibling_execution if task.most_recent_execution
    return true if executions.compact.any? { |execution| execution.state == :pending }
    false
  end

  # returns the status of the combined tasks for a product test
  #   all tasks must pass to return 'passing'
  #   if one test fails, return 'failing'
  def tasks_status(tasks)
    return tasks.first.status if tasks.count == 0
    return 'passing' if tasks.all?(&:passing?)
    return 'failing' if tasks.any?(&:failing?)
    return 'errored' if tasks.any?(&:errored?)
    return 'incomplete' if tasks.any?(&:incomplete?)
    'unstarted'
  end

  def id_for_html_wrapper_of_task(task)
    "wrapper-task-id-#{task.id}"
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

  # yields test_type, title, and description for each tab that should be displayed on product show page
  #   also yeilds html_id which should be used as the html id of the <div> tag that holds the content for each tab
  def each_tab(product)
    %w(ChecklistTest MeasureTest FilteringTest).each do |test_type|
      next unless should_show_product_tests_tab?(product, test_type)
      if test_type == 'MeasureTest'
        title, description, html_id = title_description_and_html_id_for(product, test_type, true)
        yield(test_type, title, description, html_id) if product.c1_test
        title, description, html_id = title_description_and_html_id_for(product, test_type, false)
        yield(test_type, title, description, html_id) if product.c2_test
      else
        title, description, html_id = title_description_and_html_id_for(product, test_type)
        yield(test_type, title, description, html_id)
      end
    end
  end

  def title_description_and_html_id_for(product, test_type, is_c1_measure_test = true)
    title = title_for(product, test_type, is_c1_measure_test)
    description = description_for(product, test_type, is_c1_measure_test)
    html_id = html_id_for_tab(product, test_type, is_c1_measure_test)
    [title, description, html_id]
  end

  def html_id_for_tab(product, test_type, is_c1_measure_test = true)
    title_for(product, test_type, is_c1_measure_test).tr(' ', '_').tr('(', '_').tr(')', '_').underscore
  end

  # input test_type should only be 'ChecklistTest', 'MeasureTest', or 'FilteringTest'
  # input task_type is only used to differentiate between C1 measure tests and C2 measure test tabs
  def title_for(product, test_type, is_c1_measure_test = true)
    case test_type
    when 'ChecklistTest'
      product.c3_test ? 'C1 + C3 Manual' : 'C1 Manual'
    when 'MeasureTest'
      if is_c1_measure_test
        product.c3_test ? 'C1 + C3 (QRDA-I)' : 'C1 (QRDA-I)'
      else
        product.c3_test ? 'C2 + C3 (QRDA-III)' : 'C2 (QRDA-III)'
      end
    when 'FilteringTest'
      'C4 (QRDA-I and QRDA-III)'
    end
  end

  def description_for(product, test_type, is_c1_measure_test = true)
    case test_type
    when 'ChecklistTest'
      certifications = product.c3_test ? 'C1 and C3 certifications' : 'C1 certification'
      "Validate the EHR system for #{certifications} by manually entering specified patient data for the following measures."
    when 'MeasureTest'
      if is_c1_measure_test
        what_certifications_test_for = product.c3_test ? 'record and export (C1) and submit (C3)' : 'record and export (C1)'
      else
        what_certifications_test_for = product.c3_test ? 'import and calculate (C2) and submit (C3)' : 'import and calculate (C2)'
      end
      "Test the EHR system's ability to #{what_certifications_test_for} measure based data."
    when 'FilteringTest'
      'Test the EHR system\'s ability to filter patient records.'
    end
  end

  # returns array of tasks (either all C1Tasks or all C2Tasks)
  def measure_test_tasks(product, get_c1_tasks = true)
    if get_c1_tasks
      product.product_tests.measure_tests.collect { |test| test.tasks.c1_task }
    else
      product.product_tests.measure_tests.collect { |test| test.tasks.c2_task }
    end
  end

  def measure_tests_table_row_wrapper_id(task)
    "measure-tests-table-row-wrapper-#{task.id}"
  end
end
