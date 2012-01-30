class TestResult

  include Mongoid::Document

  store_in :patient_cache
  embeds_one :value, class_name: "TestResultValue", inverse_of: :test_result_value

end