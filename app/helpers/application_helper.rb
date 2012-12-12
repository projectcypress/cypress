module ApplicationHelper
  def display_time(seconds_since_epoch)

    begin
      return Time.at(seconds_since_epoch).utc.strftime('%m/%d/%Y')
    rescue
      return "?"
    end 
  end


  def display_times(entry)
    start_time = entry.start_time.nil? ? "" : "Start Time: #{display_time(entry.start_time)}"
    end_time = entry.end_time.nil? ? "" : "End Time: #{display_time(entry.end_time)}"
    time = entry.time.nil? ? "" : "Time: #{display_time(entry.time)}"

    return "#{start_time}  #{end_time} #{time}"
  end

  def submit_method(model)
    model.new_record ? "post" : "put"
  end
  
  def submit_text(model)
    model.new_record ? "Create" : "Save"
  end
  
  def error_messages_for(model)    
    #do something here to display the errors
  end

  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end
  
  def test_execution_template(te)
    type =  te.product_test.class.to_s.underscore
    "test_executions/#{type}/show"
  end
  
  
end
