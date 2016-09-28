module TestExecutionsHelper
  include TestExecutionsResultsHelper
  include Cypress::ErrorCollector

  def displaying_cat1?(task)
    (task._type == 'C1Task') || (task._type == 'Cat1FilterTask') || task._type == 'C1ManualTask'
  end

  def task_type_to_title(task_type, c3)
    case task_type
    when 'C1Task' then c3 ? 'C1 and C3' : 'C1'
    when 'C2Task' then c3 ? 'C2 and C3' : 'C2'
    when 'Cat1FilterTask' then 'QRDA Category I'
    when 'Cat3FilterTask' then 'QRDA Category III'
    end
  end

  # task_type is String and c3_task is boolean
  # returns an array of booleans [c1, c2, c3, c4]. true if page is testing these certification types
  def current_certifications(task_type, c3_task)
    return [false, false, false, true] if task_type == 'Cat1FilterTask' || task_type == 'Cat3FilterTask'
    [task_type == 'C1Task' || task_type == 'C1ManualTask', task_type == 'C2Task', c3_task, false]
  end

  # returns the number of each type of error
  def get_error_counts(execution, task)
    h = Hash[['QRDA Errors', 'Reporting Errors', 'Submission Errors', 'Warnings'].zip(get_error_counts_helper(execution))]
    h.except!('Submission Errors', 'Warnings') unless task.product_test.product.c3_test
    h
  end

  def get_error_counts_helper(execution)
    return ['--', '--', '--'] unless execution && execution.failing?
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
    if test._type == 'MeasureTest'
      msg << task_type_to_title(task._type, task.product_test.product.c3_test)
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
    when 'incomplete' then return 'info'
    when 'passing' then return 'success'
    when 'errored' then return 'warning'
    else return 'danger'
    end
  end

  def info_title_for_product_test(product_test)
    case product_test._type
    when 'MeasureTest' then 'Measure Test Information'
    when 'FilteringTest' then 'Filtering Test Information'
    when 'ChecklistTest' then 'Manual Entry Test Information'
    else 'Test Information'
    end
  end

  def route_file_name(file_name)
    file_name.dup.tr('.', '_').force_encoding('UTF-8')
  end

  def iterate_task(task, direction)
    tests = task.product_test.product.product_tests
    tests = if task._type == 'Cat1FilterTask' || task._type == 'Cat3FilterTask'
              tests.filtering_tests.sort_by { |t| cms_int(t.cms_id) }
            else
              tests.measure_tests.sort_by { |t| cms_int(t.cms_id) }
            end
    index = tests.index(task.product_test)
    next_test = if direction == 'next'
                  tests[(index + 1) % tests.count]
                else
                  tests[(index - 1 + tests.count) % tests.count]
                end
    next_test.tasks.find_by(_type: task._type)
  end

  def should_display_expected_results(task)
    !hide_patient_calculation? && (task._type == 'C2Task' || task.product_test._type == 'FilteringTest')
  end
end
