require 'mustache'
class DataElement < Mustache
  self.template_path = __dir__
  attr_reader :data_element

  def initialize(data_element)
    @data_element = data_element
  end

  def unit_string
    "#{self['value']} #{self['unit']}"
  end

  def code_code_system_string
    "#{self['code']} (#{self['codeSystem']})"
  end

  def result_string
    return unit_string if self['unit']
    return code_code_system_string if self['code']
    ''
  end

  def facility_string
    "#{self['code']['code']} (#{self['code']['codeSystem']})"
  end
end
