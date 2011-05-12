module ApplicationHelper
  def display_time(seconds_since_epoch)
    Time.at(seconds_since_epoch).strftime('%m/%d/%Y')
  end
  
end
