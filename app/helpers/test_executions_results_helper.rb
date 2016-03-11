module TestExecutionsResultsHelper
  def get_select_history_message(execution, is_most_recent)
    msg = ''
    msg << 'Most Recent - ' if is_most_recent
    msg << execution.created_at.in_time_zone('Eastern Time (US & Canada)').strftime('%b %d, %Y at %I:%M %p (%A)')
    case execution.status_with_sibling
    when 'passing' then msg << ' (passing)'
    when 'incomplete' then msg << ' (in progress)'
    else # failing
      num_errors = execution.execution_errors.count
      num_errors += execution.sibling_execution.execution_errors.count if execution.sibling_execution
      msg << " (#{num_errors} errors)"
    end
    msg
  end

  # # # # # # # # # # # # # # # #
  #   E r r o r   T a b l e s   #
  # # # # # # # # # # # # # # # #

  def supplemental_data_errors(errors)
    return_errors = errors.select do |err|
      err.has_attribute?('error_details') && err['error_details'].key?('type') && err['error_details']['type'] == 'supplemental_data'
    end
    # sort by population key (IPP, DENOM, ...)
    return_errors.sort do |a, b|
      a.error_details.population_key <=> b.error_details.population_key
    end
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
