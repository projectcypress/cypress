class PatientCacheValue

  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :result_value, class_name: "Result", inverse_of: :value

  field :DENOM, type: Integer
  field :NUMER, type: Integer
  field :DENEX, type: Integer
  field :DENEXCEP, type: Integer
  field :MSRPOPL, type: Integer
  field :OBSERV
  field :antinumerator, type: Integer
  field :IPP, type: Integer
  field :measure_id, type: String
  field :sub_id, type: String


end
