module TestExecutionsHelper
  include TestExecutionsResultsHelper
  include Cypress::ErrorCollector

  def displaying_cat1?(task)
    # A CMSProgramTask only uses the cat I upload when the reporting_program_type is eh
    task.is_a?(C1Task) || task.is_a?(Cat1FilterTask) || task.is_a?(C1ChecklistTask) || task.is_a?(MultiMeasureCat1Task) ||
      (task.is_a?(CMSProgramTask) && task.product_test.reporting_program_type == 'eh')
  end

  def task_type_to_title(task_type)
    case task_type
    when 'C1Task'
      if @product_test.c1_test
        @product_test.c3_cat1_task? ? 'C1 and C3' : 'C1'
      else
        'C3 (QRDA-I)'
      end
    when 'C2Task'
      if @product_test.c2_test
        @product_test.c3_cat3_task? ? 'C2 and C3' : 'C2'
      else
        'C3 (QRDA-III)'
      end
    when 'Cat1FilterTask' then 'QRDA Category I'
    when 'Cat3FilterTask' then 'QRDA Category III'
    end
  end

  # task_type is String and c3_task is boolean
  # returns an array of booleans [c1, c2, c3, c4]. true if page is testing these certification types
  def current_certifications(task_type, c3_task, eh_measures, ep_measures)
    return [false, false, false, true] if %w[Cat1FilterTask Cat3FilterTask].include?(task_type)

    # matched_reporting_types are the following
    # C2 Tasks (QRDA Cat III) with ep measures
    # C1 Tasks (QRDA Cat I) with eh measures
    qrda_cat_1_task = %w[C1Task C1ChecklistTask].include?(task_type)
    matched_reporting_types = (task_type == 'C2Task' && ep_measures) || (qrda_cat_1_task && eh_measures)
    [qrda_cat_1_task, task_type == 'C2Task', matched_reporting_types && c3_task, false]
  end

  # returns the number of each type of error
  def get_error_counts(execution, task)
    h = Hash[['QRDA Errors', 'Reporting Errors', 'Submission Errors', 'Warnings'].zip(get_error_counts_helper(execution))]
    h.except!('Submission Errors', 'Warnings') unless task.product_test.product.c3_test
    h
  end

  def get_error_counts_helper(execution)
    return ['--', '--', '--'] unless execution&.failing?

    qrda = execution.execution_errors.qrda_errors.count
    reporting = execution.execution_errors.reporting_errors.count
    submit_errors = submit_warnings = 0
    if execution.sibling_execution
      submit_errors = execution.sibling_execution.execution_errors.only_errors.count
      submit_warnings = execution.sibling_execution.execution_errors.only_warnings.count
    end
    [qrda, reporting, submit_errors, submit_warnings]
  end

  def date_of_execution(execution)
    display_time_to_minutes(execution.created_at)
  end

  def get_title_message(test, task)
    msg = ''
    if test.is_a? MeasureTest
      msg << task_type_to_title(task._type)
      msg << ' certification'
      msg << 's' if test.product.c3_test
    else
      msg << 'CQM Filter'
      filters = test.options.filters.keys
      msg << 's' if filters.count > 1
      msg << " #{filters.join('/').titleize}"
    end
    msg << " for #{test.cms_id} #{test.name}"
  end

  def get_upload_type(is_displaying_cat1)
    is_displaying_cat1 ? 'zip file of QRDA Category I documents' : 'QRDA Category III XML document'
  end

  def execution_failure_message(execution)
    should_display_c3 = execution.sibling_execution ? true : false
    combined_errors = should_display_c3 ? execution.execution_errors + execution.sibling_execution.execution_errors : execution.execution_errors

    all_warnings, all_errors = combined_errors.partition { |e| e.msg_type == :warning }

    failure_message = "Failed with #{pluralize(all_errors.count, 'error')}"
    failure_message += " and #{pluralize(all_warnings.uniq { |e| [e.message, e.location, e.file_name] }.count, 'warning')}" if all_warnings.any?

    failure_message
  end

  def execution_status_class(execution)
    case execution.status_with_sibling
    when 'incomplete' then 'info'
    when 'passing' then 'success'
    when 'errored' then 'warning'
    else 'danger'
    end
  end

  def info_title_for_product_test(product_test)
    case product_test
    when MeasureTest then "#{product_test.cms_id} Measure Test"
    when FilteringTest then "#{product_test.cms_id} Filtering Test"
    when ChecklistTest then 'Record Sample Test Information'
    when MultiMeasureTest then product_test.reporting_program_type == 'eh' ? 'EH Measures Test' : 'EP/EC Measures Test'
    else 'Test Information'
    end
  end

  def route_file_name(file_name)
    file_name.dup.tr('.', '_').force_encoding('UTF-8')
  end

  def iterate_task(task, direction)
    tests = task.product_test.product.product_tests
    tests = tests_for_task_by_type(task, tests)
    index = tests.index(task.product_test)
    next_test_with_type(task._type, tests, index, direction)
  end

  def next_test_with_type(task_type, tests, index, direction)
    incremented_index = direction == 'next' ? (index + 1) : (index - 1)
    possible = tests[incremented_index % tests.count]
    if possible.tasks.where(_type: task_type).empty?
      next_test_with_type(task_type, tests, incremented_index, direction)
    else
      possible.tasks.where(_type: task_type).first
    end
  end

  def tests_for_task_by_type(task, tests)
    return tests.filtering_tests.sort_by { |t| cms_int(t.cms_id) } if task.is_a?(Cat1FilterTask) || task.is_a?(Cat3FilterTask)
    return tests.multi_measure_tests.sort_by(&:reporting_program_type) if task.is_a?(MultiMeasureCat1Task) || task.is_a?(MultiMeasureCat3Task)
    return tests.cms_program_tests.sort_by(&:name) if task.is_a?(CMSProgramTask)

    tests.measure_tests.sort_by { |t| cms_int(t.cms_id) }
  end

  def should_display_expected_results(task)
    !hide_patient_calculation? && (task.is_a?(C2Task) || task.product_test.is_a?(FilteringTest) || task.is_a?(MultiMeasureCat3Task))
  end
end
