class ChecklistSourceDataCriteria
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  embedded_in :checklist_test

  field :measure_id, type: String
  field :source_data_criteria, type: String # this is the name of the source_data_criteria

  field :completed, type: Boolean
end
