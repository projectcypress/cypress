module ApplicationHelper
  def display_time(seconds_since_epoch)
    Time.at(seconds_since_epoch).utc.strftime('%Y-%m-%d') || '?'
  end

  def display_time_to_minutes(seconds_since_epoch)
    Time.at(seconds_since_epoch).utc.strftime('%Y-%m-%d %l:%M%P')
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
end
