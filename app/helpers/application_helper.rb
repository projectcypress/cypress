module ApplicationHelper
  def display_time(seconds_since_epoch)
    Time.at(seconds_since_epoch).utc.strftime('%m/%d/%Y') || '?'
  end

  def website_link(url_string)
    uri = URI.parse(url_string)
    return url_string if uri.scheme
    "http://#{url_string}"
  end
end
