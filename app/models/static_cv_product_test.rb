class StaticCVProductTest < InpatientProductTest 



 def self.product_type_measures
    Measure.top_level().where({"population_ids.MSRPOPL" => {"$exists" => true}})
  end
end 
