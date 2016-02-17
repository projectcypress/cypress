module TestExecutionsHelper
  def displaying_cat1?(task)
    test = task.product_test
    (test._type == 'MeasureTest' && task._type == 'C1Task') || (test._type == 'FilteringTest' && task._type == 'Cat1FilterTask')
  end

  def task_type_to_title(task_type, c3)
    case task_type
    when 'C1Task' then c3 ? 'C1 and C3' : 'C1'
    when 'C2Task' then c3 ? 'C2 and C3' : 'C2'
    when 'Cat1FilterTask' then 'Cat 1'
    when 'Cat3FilterTask' then 'Cat 3'
    end
  end

  # task_type is String and c3_task is boolean
  # returns an array of booleans [c1, c2, c3, c4]. true if page is testing these certification types
  def current_certifications(task_type, c3_task)
    return [false, false, false, true] if task_type == 'Cat1FilterTask' || task_type == 'Cat3FilterTask'
    [task_type == 'C1Task', task_type == 'C2Task', c3_task, false]
  end

  def date_of_execution(execution)
    execution.created_at.in_time_zone('Eastern Time (US & Canada)').strftime('%-m/%-d/%y @ %k:%M')
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
    if is_displaying_cat1
      'zip file of QRDA Category I documents'
    else
      'QRDA Category III XML document'
    end
  end

  # returns the number of each type of error
  def get_error_counts(execution, task)
    h = Hash[['QRDA Errors', 'Reporting Errors', 'Submission Errors'].zip(get_error_counts_helper(execution))]
    h.except!('Submission Errors') unless task.product_test.product.c3_test
    h
  end

  def get_error_counts_helper(execution)
    return ['--', '--', '--'] unless execution && execution.failing?
    qrda = execution.qrda_errors.count
    reporting = execution.reporting_errors.count
    submit = execution.sibling_execution_id ? TestExecution.find(execution.sibling_execution_id).execution_errors.count : 0
    [qrda, reporting, submit]
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
