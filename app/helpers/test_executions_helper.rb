module TestExecutionsHelper
  def get_certification_types(task)
    if currently_viewing_c1?(task)
      certification_types = 'C1'
    else
      certification_types = 'C2'
    end
    certification_types << ' and C3' if task.product_test.product.c3_test
    certification_types
  end

  def get_other_certification_types(task)
    if currently_viewing_c1?(task)
      other_certification_types = 'C2'
    else
      other_certification_types = 'C1'
    end
    other_certification_types << ' and C3' if task.product_test.product.c3_test
    other_certification_types
  end

  def get_upload_type(task)
    if currently_viewing_c1?(task)
      'CAT 1 zip'
    else
      'CAT 3 XML'
    end
  end

  # returns:
  #   c1 task if we are currently on the c2 task page
  #   c2 task if we are currently on the c1 task page
  #   false if the user did not select the other task when creating the product
  def get_other_task(task)
    if currently_viewing_c1?(task)
      task.product_test.c2_task
    else
      task.product_test.c1_task
    end
  end

  def get_select_history_message(execution, is_most_recent)
    msg = ''
    msg << 'Most Recent - ' if is_most_recent
    msg << execution.created_at.in_time_zone('Eastern Time (US & Canada)').strftime('%b %d, %Y at %I:%M %p (%A)')
    msg << ' (passing)' if execution.passing?
    msg << ' (in progress)' if execution.incomplete?
    msg << " (#{execution.execution_errors.count} errors)" if execution.failing?
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
