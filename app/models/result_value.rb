class ResultValue

  include Mongoid::Document

  embedded_in :result_value, class_name: "Result", inverse_of: :value

  field :DENOM, type: Integer
  field :NUMER, type: Integer
  field :DENEX, type: Integer
  field :antinumerator, type: Integer
  field :IPP, type: Integer
  field :measure_id, type: String
  field :sub_id, type: String
  

end