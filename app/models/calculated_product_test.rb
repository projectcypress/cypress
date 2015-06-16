class CalculatedProductTest < ProductTest

  aasm :column => :state do
    state :generating_records, :after_enter => :generate_records
    state :calculating_expected_results, :after_enter => :calculate_expected_results

    event :generate_population do
      transitions :from => :pending, :to => :generating_records
    end

    event :calculate do
      transitions :from => :generating_records, :to => :calculating_expected_results
    end

  end

  has_many :qrda_product_tests, class_name: "QRDAProductTest", foreign_key: "calculated_test_id"

  #after the test is created generate the population
  after_create :gen_pop

  def gen_pop
    self.generate_population
  end

  def calculate_expected_results
    self.status_message = "Calculating Measures"
    self.save
    Delayed::Job.enqueue(Cypress::MeasureEvaluationJob.new({"test_id" =>  self.id.to_s}))
  end

  def generate_records
    min_set = PatientPopulation.min_coverage(self.measure_ids, self.bundle)
    p_ids = min_set[:minimal_set]
    overflow = min_set[:overflow]
    all = p_ids + overflow
    randomization_ids = all
    while p_ids.length < 5 && overflow.length != 0
        p_ids << overflow.sample
    end
    #randomly pick a number of other patients to give to the vendor

    # do this synchronously because it does not take long
    # p_ids = Record.where(:test_id=>nil, :type=>"ep").collect{|p| p.medical_record_number}
    pcj = Cypress::PopulationCloneJob.new({'patient_ids' =>p_ids, 'test_id' => self.id, "randomize_names"=> true, "randomization_ids" => randomization_ids})
    pcj.perform

    self.records.each do |r|
      r.medical_record_assigner = "Cypress" if r.medical_record_assigner.nil?
      r.save!
    end
    #now calculate the expected results
    self.calculate
  end

  def validators(doc)
    @validators ||= [::Validators::QrdaCat3Validator.new(expected_results),
      ::Validators::MeasurePeriodValidator.new(),
      ::Validators::ExpectedResultsValidator.new(expected_results)]
  end

  def execute(qrda_file)

    data = qrda_file.open.read
    doc = Nokogiri::XML(data)
    te = self.test_executions.build(expected_results:self.expected_results,
	   execution_date: Time.now.to_i)
    te.artifact = Artifact.new(file: qrda_file)
    te.save
    te.validate_artifact(validators(doc))

    te.save
    te
  end

  def generate_qrda_cat1_test
    product_measures = self.qrda_product_tests.map(&:measures).flatten
    (self.measures.top_level - product_measures).each do |mes|
      generate_results_for_measure(mes)
    end

    self.save
  end

  def self.product_type_measures(bundle)
    bundle.measures.top_level_by_type("ep") #.where({"population_ids.MSRPOPL" => {"$exists" => false}})
  end

  private

  def generate_results_for_measure(mes)
    results = self.results.where({"value.measure_id" => mes.hqmf_id, "value.IPP" => {"$gt" => 0}})
    mrns = results.collect{|r| r["value"]["medical_record_id"]}
    results.uniq!
    qrda = qrda_product_tests.build(measure_ids: [mes.measure_id],
	    parent_cat3_ids: measure_ids,
	    name: "#{self.name} - Measure #{mes.nqf_id} QRDA Cat I Test",
	    bundle_id: self.bundle_id,
            effective_date: self.effective_date,
            product_id: self.product_id,
            user_id: self.user_id)
    records = self.records.where({"medical_record_number" => {"$in"=>mrns}})

    records.each do |rec|
      generate_new_results(rec, results, qrda.id)
    end

    qrda.save
    qrda.ready
  end

  def generate_new_results(rec, results, qrda_id)
    new_results = results.select { |res| res.value.patient_id == rec.id }

    new_rec = rec.dup
    new_rec[:test_id] = qrda_id
    new_rec.save

    new_results.each do |res|
      update_new_result_ids(res, qrda_id, new_rec.id)
    end
  end

  def update_new_result_ids(res, qrda_id, new_rec_id)
    res_clone = Result.new()
    res_clone["value"] = res["value"].clone
    res_clone["value"]["test_id"]=qrda_id
    res_clone["value"]["patient_id"] = new_rec_id
    res_clone.save
  end

end
