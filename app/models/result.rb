class Result
  include Mongoid::Document

  store_in collection: :patient_cache
  embeds_one :value, class_name: "ResultValue", inverse_of: :result_value
end