class ResultValue

  include Mongoid::Document

  embedded_in :result_value, class_name: "Result", inverse_of: :value

  belongs_to :patient, class_name: "Record"

  field :denominator, type: Boolean
  field :numerator, type: Boolean
  field :exclusions, type: Boolean
  field :antinumerator, type: Boolean
  field :population, type: Boolean
  field :measure_id, type: String
  field :sub_id, type: String

end