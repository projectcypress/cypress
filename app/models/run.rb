class Test

  include Mongoid::Document

  embedded_in :vendor, class_name: "Vendor", inverse_of: :tests  
  field :effective_date, type: Integer
end