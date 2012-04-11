module ApplicationHelper
  def display_time(seconds_since_epoch)
    begin
     return Time.at(seconds_since_epoch).strftime('%m/%d/%Y')
    rescue
      return "?"
    end 
  end
  
  def submit_method(model)
    model.new? ? "post" : "put"
  end
  
  def submit_text(model)
    model.new? ? "Create" : "Save"
  end
  
  
  def error_messages_for(model)
    
    #do something here to display the errors
  end
end
