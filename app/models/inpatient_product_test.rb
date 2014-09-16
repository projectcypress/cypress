class InpatientProductTest < CalculatedProductTest

  #after the test is created generate the population
  after_create :gen_pop



  def self.product_type_measures(bundle)
    bundle.measures.top_level_by_type("eh") #.where({"population_ids.MSRPOPL" => {"$exists" => false}})
  end

end
