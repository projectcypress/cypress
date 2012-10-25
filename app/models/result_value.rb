class ResultValue


  def patient
    Record.find(self['patient_id'])
  end


  def record
    Record.find(self['patient_id'])
  end

  include Mongoid::Document

  embedded_in :result_value, class_name: "Result", inverse_of: :value



  field :denominator, type: Boolean
  field :numerator, type: Boolean
  field :exclusions, type: Boolean
  field :antinumerator, type: Boolean
  field :population, type: Boolean
  field :measure_id, type: String
  field :sub_id, type: String

end