class Result
  include Mongoid::Document
  field :bundle_id
  store_in collection: :patient_cache
  index "value.last" => 1
  index "bundle_id" => 1
  embeds_one :value, class_name: "PatientCacheValue", inverse_of: :result_value

  def record
  	filter = {:medical_record_number => value['medical_record_id'], :test_id => value["test_id"]}
  	filter[:bundle_id] =  self.bundle_id if  self.bundle_id
  	Record.where(filter).first
  end


end