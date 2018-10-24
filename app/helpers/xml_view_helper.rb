module XmlViewHelper
  include Cypress::ErrorCollector
  # used for errors popup in node partial
  #   returns title of popup, popup button text, and message in popup
  def popup_attributes(errors)
    return unless errors.count.positive?

    title = "Execution #{'Error'.pluralize(errors.count)} (#{errors.count})"
    button_text = " view #{'error'.pluralize(errors.count)} (#{errors.count})"
    message = ''
    if errors.count > 1
      errors.each do |error|
        # error_#{error.id} class is added so error can be highlighted if popup contains multiple errors
        message << "<li class = 'error_#{error.id}'>#{error.message}</li>"
      end
    else
      message << errors.first.message
    end

    [title, button_text, message]
  end

  private

  def data_to_doc(data)
    if data.is_a? String
      Nokogiri::XML(data)
    else
      data
    end
  end
end
