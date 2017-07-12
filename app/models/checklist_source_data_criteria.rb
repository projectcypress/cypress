class ChecklistSourceDataCriteria
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  embedded_in :checklist_test

  field :measure_id, type: String
  field :source_data_criteria, type: String # this is the name of the source_data_criteria
  field :replacement_data_criteria, type: String

  field :recorded_result, type: String
  field :code, type: String
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
    if replacement_data_criteria && replacement_data_criteria != source_data_criteria
      checklist_test.checked_criteria.create(measure_id: measure_id, source_data_criteria: replacement_data_criteria,
                                             negated_valueset: false, replacement_data_criteria: replacement_data_criteria)
      delete
    end
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
    if recorded_result
      self.result_complete = recorded_result == '' ? false : true
    end
  end

  def attribute_code_matches_valueset?
    # validate if an attribute_code is required and is correct
    if attribute_code
      measure = Measure.find_by(_id: measure_id)
      criteria = measure.hqmf_document[:data_criteria].select { |key| key == source_data_criteria }.values.first
      valueset = if criteria[:field_values]
                   [criteria[:field_values].values[0].code_list_id]
                 elsif criteria[:value]
                   [criteria[:value].code_list_id]
                 else
                   [criteria.negation_code_list_id]
                 end
      self.attribute_complete = code_in_valuesets(valueset, attribute_code, measure.bundle_id)
    end
  end

  def code_matches_valueset?
    # validate if an code is required and is correct
    if code
      valuesets = get_all_valuesets_for_dc(measure_id)
      self.code_complete = code_in_valuesets(valuesets, code, Measure.find_by(_id: measure_id).bundle_id)
    end
  end

  def printable_name
    measure = Measure.find_by(_id: measure_id)
    sdc = measure.hqmf_document[:data_criteria].select { |key, _value| key == source_data_criteria }.values.first
    sdc['status'] ? "#{measure.cms_id} - #{sdc['definition']}, #{sdc['status']}" : "#{measure.cms_id} - #{sdc['definition']}"
  end

  # goes through all data criteria in a measure to find valuesets that have the same type, status and field values
  def get_all_valuesets_for_dc(measure_id)
    measure = Measure.find_by(_id: measure_id)
    criteria = measure.hqmf_document[:data_criteria].select { |key| key == source_data_criteria }.values.first
    arr = []
    # if criteria is a characteristic, only return a single valueset
    if criteria['type'] == 'characteristic'
      arr << criteria.code_list_id
    else
      valuesets = measure.all_data_criteria.map { |data_criteria| include_valueset(data_criteria, criteria) }
      valuesets.uniq.each do |valueset|
        arr << valueset unless valueset.nil?
      end
    end
    arr
  end

  # data_criteria is from the measure defintion, criteria is for the specific checklist test
  def include_valueset(data_criteria, criteria)
    include_vset = false
    if data_criteria.type.to_s == criteria['type'] && data_criteria.status == criteria['status']
      # value set should not be included if there is a negation, and the negation doesn't match
      return nil if criteria.negation && criteria.negation_code_list_id != data_criteria.negation_code_list_id
      # if the criteria has a field_value, check it is the same as the data_criteria, else return true
      include_vset = criteria['field_values'] ? compare_field_values(data_criteria, criteria) : true
    end
    data_criteria.code_list_id if include_vset
  end

  # data_criteria is from the measure defintion, criteria is for the specific checklist test
  def compare_field_values(data_criteria, criteria)
    include_vset = false
    if data_criteria.field_values && criteria['field_values'].keys[0] == data_criteria.field_values.keys[0]
      if data_criteria.field_values.values[0].type == 'CD'
        if data_criteria.field_values.values[0].code_list_id == criteria['field_values'].values[0]['code_list_id']
          include_vset = true
        end
      else
        include_vset = true
      end
    end
    include_vset
  end

  # searches an array of valuesets for a code
  def code_in_valuesets(valuesets, input_code, bundle_id)
    !HealthDataStandards::SVS::ValueSet.where('concepts.code' => input_code, bundle_id: bundle_id).in(oid: valuesets).empty?
  end
end
