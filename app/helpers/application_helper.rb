module ApplicationHelper
  def display_time(seconds_since_epoch)
    Time.at(seconds_since_epoch).utc.strftime('%m/%d/%Y') || '?'
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
end
