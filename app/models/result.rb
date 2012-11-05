class Result
  include Mongoid::Document

  store_in collection: :patient_cache
  embeds_one :value, class_name: "ResultValue", inverse_of: :result_value

  def record

  	Record.where(:medical_record_number => value['medical_record_id'], :test_id => value["test_id"]).first
  end

end