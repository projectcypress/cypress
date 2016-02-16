module TestExecutionsHelper
  def displaying_cat1?(task)
    test = task.product_test
    (test._type == 'MeasureTest' && task._type == 'C1Task') || (test._type == 'FilteringTest' && task._type == 'Cat1FilterTask')
  end

  def get_title_message(test, task)
    msg = ''
    if test._type == 'MeasureTest'
      msg << get_measure_certification_types(task).to_s
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

  def get_measure_certification_types(task)
    certification_types = currently_viewing_c1?(task) ? 'C1' : 'C2'
    certification_types << ' and C3' if task.product_test.product.c3_test
    certification_types
  end

  def get_upload_type(is_displaying_cat1)
    if is_displaying_cat1
      'zip file of QRDA Category I documents'
    else
      'QRDA Category III XML document'
    end
  end

  # returns:
  #   c1 task if we are currently on the c2 task page and the product test is a measure_test
  #   c2 task if we are currently on the c1 task page and the product test is a measure_test
  #   cat1 task if we are currently on the cat3 task page and the product test is a filter_test
  #   cat3 task if we are currently on the cat1 task page and the product test is a filter_test
  #   false if the user did not select the other task when creating the product
  def get_other_task(task)
    test = task.product_test
    if test._type == 'MeasureTest'
      if currently_viewing_c1?(task)
        test.c2_task
      else
        test.c1_task
      end
    elsif task._type == 'Cat1FilterTask'
      test.cat3_task
    else
      test.cat1_task
    end
  end

  # returns the number of each type of error
  def get_error_counts(execution)
    qrda = reporting = submit = total = 0
    return [qrda, reporting, submit, total] unless execution && execution.failing?
    qrda = execution.qrda_errors.count
    reporting = execution.reporting_errors.count
    submit = TestExecution.find(execution.sibling_execution_id).execution_errors.count if execution.sibling_execution_id
    total = qrda + reporting + submit
    [qrda, reporting, submit, total]
  end

  def get_select_history_message(execution, is_most_recent)
    msg = ''
    msg << 'Most Recent - ' if is_most_recent
    msg << execution.created_at.in_time_zone('Eastern Time (US & Canada)').strftime('%b %d, %Y at %I:%M %p (%A)')
    msg << ' (passing)' if execution.passing?
    msg << ' (in progress)' if execution.incomplete?
    if execution.failing?
      num_errors = execution.execution_errors.count
      num_errors += TestExecution.find(execution.sibling_execution_id).execution_errors.count if execution.sibling_execution_id
      msg << " (#{num_errors} errors)"
    end
    msg
  end

  # only use if an xpath location is specified for error
  def get_line_number(error)
    error_to_line_number(error, get_doc(error.test_execution.artifact, error.file_name))
  end

  # inputs: a and b are execution errors
  # returns: 1 if a should be sorted first or -1 if b should be sorted first
  #   1 if a is from an aphabetically higher document or higher location in the same document
  #  -1 if b is ...
  def compare_error_locations_across_files(a, b)
    return 1 if a.file_name.nil?
    return -1 if b.file_name.nil?
    return a.file_name <=> b.file_name if a.file_name != b.file_name
    return 1 if a.location.nil?
    return -1 if b.location.nil?
    a.location <=> b.location
  end

  private

  def currently_viewing_c1?(task)
    task._type == 'C1Task'
  end

  # used for sorting errors by appearance in xml
  #   if no doc or xml element found then line number of 0 is returned
  def error_to_line_number(error, doc)
    return 0 unless doc
    nodes = doc.search(error.location)
    return 0 if nodes.count == 0 || nodes.first.class != Nokogiri::XML::Element
    nodes.first.line
  end

  def get_doc(artifact, file_name)
    artifact.each_file do |name, data|
      return data_to_doc(data) if name == file_name
    end
    false
  end
end
