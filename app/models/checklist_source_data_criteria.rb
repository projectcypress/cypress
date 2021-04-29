# frozen_string_literal: true

class ChecklistSourceDataCriteria
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  embedded_in :checklist_test

  field :measure_id, type: String
  field :source_data_criteria, type: Hash
  field :replacement_data_criteria, type: String
  field :replacement_attribute, type: String

  field :recorded_result, type: String
  field :code, type: String
  field :attribute_index, type: Integer
  field :negated_valueset, type: Boolean
  field :attribute_code, type: String
  field :passed_qrda, type: Boolean
  field :selected_negated_valueset, type: String
  field :additional_code, type: String

  field :code_complete, type: Boolean
  field :attribute_complete, type: Boolean
  field :result_complete, type: Boolean

  def validate_criteria
    self.passed_qrda = false
    result_completed?
    attribute_code_matches_valueset?
    code_matches_valueset?
  end

  def change_criteria
    if replacement_data_criteria && replacement_data_criteria != source_data_criteria._id.to_s
      measure = Measure.find_by(_id: measure_id)
      new_source_data_criteria = measure.source_data_criteria.find(replacement_data_criteria).attributes.slice(
        'qdmCategory', 'qdmStatus', '_type', 'description', 'codeListId', '_id', 'hqmfOid', 'dataElementAttributes'
      )
      new_attribute_index = if change_attribute?(new_source_data_criteria)
                              # find attribute index for new criteria
                              index_for_replacement_attribute(new_source_data_criteria)
                            else
                              checklist_test.attribute_index(new_source_data_criteria)
                            end
      checklist_test.checked_criteria.create(measure_id: measure_id, source_data_criteria: new_source_data_criteria,
                                             negated_valueset: false, replacement_data_criteria: replacement_data_criteria,
                                             attribute_index: new_attribute_index)
      delete
    elsif change_attribute?(source_data_criteria)
      update_attribute
    end
  end

  def update_attribute
    self.attribute_complete = nil
    self.result_complete = nil

    # replacement attribute only

    self.attribute_index = index_for_replacement_attribute(source_data_criteria)
    if source_data_criteria['dataElementAttributes'][attribute_index]['attribute_valueset']
      # initially set as empty
      self.attribute_code = ''
      self.recorded_result = nil
    else
      self.attribute_code = nil
      self.recorded_result = ''
    end
  end

  def index_for_replacement_attribute(criteria)
    attributes = criteria['dataElementAttributes']
    return nil if attributes.blank? || replacement_attribute.blank?

    return attributes.index { |a| a.attribute_name == replacement_attribute } unless replacement_attribute.include?(':')

    name, valueset = replacement_attribute.split(':')
    attributes.index { |a| a.attribute_name == name && a.attribute_valueset == valueset }
  end

  def change_attribute?(criteria)
    return false unless replacement_attribute
    return false unless criteria['dataElementAttributes']&.any?
    return false unless criteria['dataElementAttributes'][attribute_index]

    attr = criteria['dataElementAttributes'][attribute_index]
    comp_str = attr['attribute_name']
    comp_str = "#{comp_str}:#{attr['attribute_valueset']}" if attr['attribute_valueset']
    replacement_attribute != comp_str
  end

  def checklist_complete?
    if code.blank? && attribute_code.blank? && recorded_result.blank?
      nil
    elsif negated_valueset
      attribute_complete != false
    else
      code_complete != false && attribute_complete != false && result_complete != false
    end
  end

  def complete?
    checklist_complete? && passed_qrda
  end

  def result_completed?
    self.result_complete = recorded_result != '' if recorded_result
  end

  def attribute_code_matches_valueset?
    # validate if an attribute_code is required and is correct
    return unless attribute_code.present?

    measure = Measure.find_by(_id: measure_id)
    valueset = source_data_criteria['dataElementAttributes'][attribute_index]['attribute_valueset'] if source_data_criteria['dataElementAttributes']
    self.attribute_complete = code_in_valuesets(valueset, attribute_code, measure.bundle_id)
  end

  def code_matches_valueset?
    # validate if an code is required and is correct
    return unless code

    valuesets = get_all_valuesets_for_dc(measure_id)
    self.code_complete = code_in_valuesets(valuesets, code, Measure.find_by(_id: measure_id).bundle_id)
  end

  def printable_name
    measure = Measure.find_by(_id: measure_id)
    return "#{measure.cms_id} - #{source_data_criteria['qdmCategory']}" unless source_data_criteria['qdmStatus']

    "#{measure.cms_id} - #{source_data_criteria['qdmCategory']}, #{source_data_criteria['qdmStatus']}"
  end

  # goes through all data criteria in a measure to find valuesets that have the same type, status and field values
  def get_all_valuesets_for_dc(measure_id)
    measure = Measure.find_by(_id: measure_id)
    measure.reload
    arr = []
    # if criteria is a characteristic, only return a single valueset
    if source_data_criteria.qdmCategory == 'patient_characteristic'
      arr << source_data_criteria.codeListId
    else
      valuesets = measure.source_data_criteria.map { |data_criteria| include_valueset(data_criteria, source_data_criteria) }
      valuesets.uniq.each do |valueset|
        arr << valueset unless valueset.nil?
      end
    end
    arr
  end

  # data_criteria is from the measure defintion, criteria is for the specific checklist test
  def include_valueset(data_criteria, criteria)
    include_vset = false
    if data_criteria._type == criteria['_type']
      # value set should not be included if there is a negation, and the negation doesn't match
      # if the criteria has a field_value, check it is the same as the data_criteria, else return true
      include_vset = criteria['dataElementAttributes']&.any? ? compare_attributes(data_criteria, criteria) : true
    end
    data_criteria.codeListId if include_vset
  end

  # data_criteria is from the measure defintion, criteria is for the specific checklist test
  def compare_attributes(data_criteria, criteria)
    return false unless data_criteria['dataElementAttributes']&.any?

    data_criteria['dataElementAttributes'].map { |dc| dc.except('_id') }.include? criteria['dataElementAttributes'][attribute_index].except('_id')
  end

  # searches an array of valuesets for a code
  def code_in_valuesets(valuesets, input_code, bundle_id)
    # if valueset is a "direct reference code" check to see if input_code matches ones of the "valuesets"
    return true if valuesets.include? input_code

    !ValueSet.where('concepts.code' => input_code, bundle_id: bundle_id).in(oid: valuesets).empty?
  end
end
