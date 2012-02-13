module ApplicationHelper
  def display_time(seconds_since_epoch)
    begin
     return Time.at(seconds_since_epoch).strftime('%m/%d/%Y')
    rescue
      return "?"
    end 
  end
end
