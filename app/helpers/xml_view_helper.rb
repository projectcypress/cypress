module XmlViewHelper
  include Cypress::ErrorCollector
  # used for errors popup in node partial
  #   returns title of popup, popup button text, and message in popup
  def popup_attributes(errors)
    return unless errors.count > 0
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

  NODE_TYPES = {
    1 => :element, 2 => :attribute, 3 => :text, 4 => :cdata, 5 => :ent_ref, 6 => :entity,
    7 => :instruction, 8 => :comment, 9 => :document, 10 => :doc_type, 11 => :doc_frag, 12 => :notaion
  }.freeze

  def get_error_id(element, uuid)
    element = element.root if node_type(element.type) == :document
    element['error_id'] = uuid.generate.to_s unless element['error_id']
    element['error_id']
  end

  def node_type(type)
    NODE_TYPES[type]
  end

  def data_to_doc(data)
    if data.is_a? String
      Nokogiri::XML(data)
    else
      data
    end
  end
end
