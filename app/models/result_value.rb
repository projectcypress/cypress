class ResultValue

  include Mongoid::Document

  embedded_in :result_value, class_name: "Result", inverse_of: :value

  field :denominator, type: Integer
  field :numerator, type: Integer
  field :exclusions, type: Integer
  field :antinumerator, type: Integer
  field :population, type: Integer
  field :measure_id, type: String
  field :sub_id, type: String
  

end