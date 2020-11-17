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

  def ecqi_link(cms_id)
    measure = Measure.where(cms_id: cms_id).first
    return unless measure

    program = measure.reporting_program_type
    year = Bundle.find(measure.bundle_id).major_version.to_i + 1
    "https://ecqi.healthit.gov/ecqm/#{program}/#{year}/#{padded_cms_id(cms_id)}"
  end

  # This will always return a three digit cms identifier, e.g., CMS9v3 => CMS009v3
  def padded_cms_id(cms_id)
    cms_id.sub(/(?<=cms)(\d{1,3})/i) { Regexp.last_match(1).rjust(3, '0') }
  end
end
