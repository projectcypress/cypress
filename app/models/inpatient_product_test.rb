class InpatientProductTest < CalculatedProductTest
   
  #after the test is created generate the population
  after_create :generate_population

  
  def generate_population
    self.expected_results = {}
    medical_record_number_mapping = {}
    rand_prefix = Time.new.to_i
    Record.where({test_id: nil, type: :eh}).in(measure_ids: measure_ids).each_with_index do |rec,index|
      cloned = rec.clone
      cloned.test_id = self.id
      mrn = cloned.medical_record_number
      new_mrn = "#{rand_prefix}#{index}"
      medical_record_number_mapping[mrn] = new_mrn
      cloned.medical_record_number = new_mrn

      cloned.save
    end 

    Result.where("value.test_id" => nil).in("value.measure_id" => measure_ids).each do |res|
      cloned = res.clone
      cloned.value["test_id"] = self.id
      mrn = cloned.value["medical_record_id"]
      new_mrn = medical_record_number_mapping[mrn]
      cloned.value["medical_record_id"] = new_mrn
      cloned.save
    end

    measures.each do |measure|

      # todo implement this
      qr = QME::QualityReport.new(measure.hqmf_id, measure.sub_id, 'effective_date' => self.effective_date, 'test_id' => nil, 'filters' => nil)
      if qr.calculated?
       self.expected_results[measure.key] = qr.result.dup
      else
 
      end  
    end
    self.save
    self.ready
  end

  
  def self.product_type_measures
    Measure.top_level_by_type("eh")
  end
  
end