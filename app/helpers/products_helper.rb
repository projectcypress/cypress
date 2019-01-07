# rubocop:disable Metrics/ModuleLength
module ProductsHelper
  # used in product create
  def should_show_product_tests_tab?(product, test_type)
    case test_type
    when 'MeasureTest'
      product.product_tests.measure_tests.any?
    when 'FilteringTest'
      product.product_tests.filtering_tests.any?
    when 'ChecklistTest'
      product.c1_test # should not check for existance of checklist test since there a user can delete checklist tests
    else
      product.product_tests.any?
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

  # input tasks should be array of (c1 or c2 task) and (c3 task if c3 was selected on product)
  # true if the task's product test is still building or if there is a test execution currently running
  def should_reload_product_test_link?(task_status, test)
    # We should reload if the test is in any state other than ready or errored
    return true unless %i[ready errored].include? test.state
    # We should reload if any tasks are pending
    return true if task_status.eql? 'pending'

    false
  end

  def should_reload_product_test_status_display?(tests)
    tests.each do |test|
      if should_reload_product_test_link?(tasks_status(with_c3_task(test.cat1_task)), test) ||
         should_reload_product_test_link?(tasks_status(with_c3_task(test.cat3_task)), test)
        return true
      end
    end
    false
  end

  def measure_test_running_for_row?(task)
    return true unless %i[ready errored].include? task.product_test_state
    return true if task.most_recent_execution && task.most_recent_execution.status_with_sibling == 'incomplete'
    # Check if the task has been refreshed within the past 30 seconds. If it has then keep refreshing until
    # the database has a chance to settle.
    return true if task.most_recent_execution && (Time.now.utc - task.most_recent_execution.last_updated_with_sibling) < 30

    false
  end

  # Takes a collection of tasks and determines if a measure test is running for any of the tasks.
  # If one is then we need to be refreshing the measure tests table.
  def should_reload_measure_test_table?(tasks)
    tasks.each do |task|
      return true if measure_test_running_for_row?(task)
    end
    false
  end

  # returns the status of the combined tasks for a product test
  #   all tasks must pass to return 'passing'
  #   if one test fails, return 'failing'
  def tasks_status(tasks)
    return 'passing' if tasks.all?(&:passing?)
    return 'failing' if tasks.any?(&:failing?)
    return 'errored' if tasks.any?(&:errored?)
    return 'pending' if tasks.any?(&:pending?)
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

    case task
    when C1Task
      return [task, task.product_test.tasks.c3_cat1_task]
    when C2Task
      return [task, task.product_test.tasks.c3_cat3_task]
    end
    [task]
  end

  # yields test_type, title, and description for each tab that should be displayed on product show page
  #   also yeilds html_id which should be used as the html id of the <div> tag that holds the content for each tab
  def each_tab(product)
    %w[ChecklistTest MeasureTest FilteringTest].each do |test_type|
      next unless should_show_product_tests_tab?(product, test_type)

      if test_type == 'MeasureTest'
        title, description, html_id = title_description_and_html_id_for(product, test_type, true)
        yield(test_type, title, description, html_id) if product.c1_test || product.c3_test
        title, description, html_id = title_description_and_html_id_for(product, test_type, false)
        yield(test_type, title, description, html_id) if product.c2_test || product.c3_test
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
    title_for(product, test_type, is_c1_measure_test).tr(' ', '_').tr('(', '_').tr(')', '_').tr('+', '_').underscore
  end

  # input test_type should only be 'ChecklistTest', 'MeasureTest', or 'FilteringTest'
  # input task_type is only used to differentiate between C1 measure tests and C2 measure test tabs
  def title_for(product, test_type, is_c1_measure_test = true)
    case test_type
    when 'ChecklistTest'
      product.c3_test ? 'C1 + C3 Sample' : 'C1 Sample'
    when 'MeasureTest'
      measure_test_title(product, is_c1_measure_test)
    when 'FilteringTest'
      'C4 (QRDA-I and QRDA-III)'
    end
  end

  def measure_test_title(product, is_c1_measure_test = true)
    if is_c1_measure_test
      if product.c1_test && product.c3_test
        'C1 + C3 (QRDA-I)'
      elsif product.c1_test
        'C1 (QRDA-I)'
      else
        'C3 (QRDA-I)'
      end
    elsif product.c2_test && product.c3_test
      'C2 + C3 (QRDA-III)'
    elsif product.c2_test
      'C2 (QRDA-III)'
    else
      'C3 (QRDA-III)'
    end
  end

  def description_for(product, test_type, is_c1_measure_test = true)
    case test_type
    when 'ChecklistTest'
      certifications = product.c3_test ? 'C1 and C3 certifications' : 'C1 certification'
      "Validate the EHR system for #{certifications} by entering specified patient data for the following measures."
    when 'MeasureTest'
      what_certifications_test_for = if is_c1_measure_test
                                       product.c3_test ? 'record and export (C1) and submit (C3)' : 'record and export (C1)'
                                     else
                                       product.c3_test ? 'import and calculate (C2) and submit (C3)' : 'import and calculate (C2)'
                                     end
      "Test the EHR system's ability to #{what_certifications_test_for} measure based data."
    when 'FilteringTest'
      'Test the EHR system\'s ability to filter patient records.'
    end
  end

  # returns array of tasks (either all C1Tasks or all C2Tasks)
  def measure_test_tasks(product, get_c1_tasks = true)
    # This function was previously sometimes returning results with a false value in front of them,
    # and it would look something like [false, <Task...>], which was then causing problems because
    # we call .first on the returned data. This was causing intermittent test failures, by rejecting
    # blank values we avoid this problem.
    if get_c1_tasks
      product.product_tests.measure_tests.collect { |test| test.tasks.c1_task }.reject(&:blank?)
    else
      product.product_tests.measure_tests.collect { |test| test.tasks.c2_task }.reject(&:blank?)
    end
  end

  def measure_tests_table_row_wrapper_id(task)
    "measure-tests-table-row-wrapper-#{task.id}"
  end

  # Should a C1 or C2 status column be displayed, or only the C3
  def include_first_task(product, first_task_type)
    case first_task_type
    when 'C1Task'
      # True - Display "C1 column" when the first task type being displayed is a C1Task and the product has a C1 test
      # False - Don't display "C1 column" when the product does not have a C1 test
      product.c1_test
    when 'C2Task'
      # True - Display "C2 column" when the first task type being displayed is a C2Task and the product has a C2 test
      # False - Don't display "C2 column" when the product does not have a C2 test
      product.c2_test
    end
  end
end
# rubocop:enable Metrics/ModuleLength
