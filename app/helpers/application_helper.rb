module ApplicationHelper
  def display_time(seconds_since_epoch)
    Time.at(seconds_since_epoch).in_time_zone.strftime('%B %e, %Y') || '?'
  end

  def display_time_to_minutes(seconds_since_epoch)
    Time.at(seconds_since_epoch).in_time_zone.strftime('%B %e, %Y %l:%M%P')
  end

  def website_link(url_string)
    uri = URI.parse(url_string)
    return url_string if uri.scheme
    "http://#{url_string}"
  end

  def make_title
    return @title if @title
    @title = case action_name
             when 'index'
               "#{controller_name} List"
             when 'show'
               controller_name.singularize
             when 'edit'
               "#{action_name} #{controller_name}"
             else
               "#{action_name} #{controller_name.singularize}"
             end
    @title.titleize
  end

  def cms_int(cms_id)
    # this is here because sometimes we only have the cms_id string and not the measure
    return 0 unless cms_id
    start_marker = 'CMS'
    end_marker = 'v'
    cms_id[/#{start_marker}(.*?)#{end_marker}/m, 1].to_i
  end

  # This will always return a three digit cms identifier, e.g., CMS9v3 => CMS009v3
  def padded_cms_id(cms_id)
    cms_id.sub(/(?<=cms)(\d{1,3})/i) { Regexp.last_match(1).rjust(3, '0') }
  end

  # All "Master Patients" has medical records numbers that are UUIDs following this pattern "007f5da0-4d3a-0135-867f-20999b0ed66f".
  # These medical record numbers are set in the bundle. When patients are created for a test,
  # they have a medical record number like "757442430658921". This "keep_if" statement makes sure we only returning an id for a Master Patient.
  #TODO R2P: use correlation id to confirm master-patient list
  def mpl_id?(patient_id)
    patient_id[8] == '-'
  end

  def product_status_row(hash, status)
    # uses the hash provided by the get_product_status_values method
    row_values = [0, 0, 0, 0, 0, 0, 0, 0]
    c1_status_row(hash, status, row_values) if hash.key?('C1')
    row_values[2] = hash['C2']['QRDA Category III'][status] if hash.key?('C2')
    c3_status_row(hash, status, row_values) if hash.key?('C3')
    c4_status_row(hash, status, row_values) if hash.key?('C4')
    row_values
  end

  def c1_status_row(hash, status, row_values)
    row_values[0] = hash['C1']['Checklist'][status] if hash['C1'].key?('Checklist')
    row_values[1] = hash['C1']['QRDA Category I'][status]
  end

  def c3_status_row(hash, status, row_values)
    row_values[3] = hash['C3']['Checklist'][status] if hash.key?('C1') && hash['C1'].key?('Checklist') # C3 only has checklist tests if C1
    row_values[4] = hash['C3']['QRDA Category I'][status]
    row_values[5] = hash['C3']['QRDA Category III'][status]
  end

  def c4_status_row(hash, status, row_values)
    row_values[6] = hash['C4']['QRDA Category I'][status]
    row_values[7] = hash['C4']['QRDA Category III'][status]
  end
end
