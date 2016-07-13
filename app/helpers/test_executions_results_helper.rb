module TestExecutionsResultsHelper
  include ActionView::Helpers::TextHelper

  def get_select_history_message(execution, is_most_recent)
    msg = ''
    msg << 'Most Recent - ' if is_most_recent
    msg << execution.created_at.in_time_zone.strftime('%B %e, %Y %l:%M%P')
    case execution.status_with_sibling
    when 'passing' then msg << ' (passing)'
    when 'incomplete' then msg << ' (in progress)'
    when 'errored' then msg << ' (internal error)'
    else # failing
      num_errors = execution.execution_errors.count
      num_errors += execution.sibling_execution.execution_errors.count if execution.sibling_execution
      msg << " (#{pluralize(num_errors, 'error')})"
    end
    msg
  end

  # # # # # # # # # # # # # # # #
  #   E r r o r   T a b l e s   #
  # # # # # # # # # # # # # # # #

  def population_data_errors(errors, population_type)
    return_errors = errors.select do |err|
      err.has_attribute?('error_details') && err['error_details'].key?('type') && err['error_details']['type'] == population_type
    end
    # sort by population id (since measures can have multiple IPP, DENOM, ...)
    return_errors.sort do |a, b|
      a.error_details.population_id <=> b.error_details.population_id
    end
  end

  def population_errors_by_population_id(errors, population_id)
    population_errors = errors.select do |err|
      err.error_details['population_id'] == population_id && !err.error_details['stratification'] && err.error_details['type'] == 'population'
    end
    stratification_errors = errors.select do |err|
      err.error_details['population_id'] == population_id && err.error_details['stratification'] && err.error_details['type'] == 'population'
    end
    supplemental_errors = errors.select do |err|
      err.error_details['population_id'] == population_id && err.error_details['type'] == 'supplemental_data'
    end
    [population_errors, stratification_errors, supplemental_errors]
  end

  # Iterates through supplemental data errors to find populations that have errors messages.
  def population_error_hash(pop_errors, sup_data_errors)
    population_key_hash = {}
    sup_data_errors.each do |supplemental_data_error|
      unless population_key_hash.key? supplemental_data_error.error_details['population_id']
        population_key_hash[supplemental_data_error.error_details['population_id']] = nil
      end
    end
    pop_errors.each do |pop_error|
      if pop_error.has_attribute?('error_details') && pop_error['error_details'].key?('population_id')
        population_key_hash[pop_error.error_details['population_id']] = true
      end
    end
    population_key_hash
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
