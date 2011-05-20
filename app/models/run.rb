class Run
  include Mongoid::Document
  embedded_in :vendor, class_name: "Vendor", inverse_of: :tests  
  field :effective_date, type: Integer
  field :measure_ids, type: Array
end