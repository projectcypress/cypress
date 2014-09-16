
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
    #now calculate the expected results
    self.calculate
  end

  def initialize(options = {})
    super(options)
  end

  def execute(params)

    qrda_file = params[:results]
    data = qrda_file.open.read
    doc = Nokogiri::XML(data)

    matched_results = {}
    reported_results = {}

    validation_errors = Cypress::QrdaUtility.validate_cat3(data) || []

    expected_results.each_pair do |key,expected_result|
      result_key = expected_result["population_ids"].dup

      reported_result, errors = Cypress::QrdaUtility.extract_results_by_ids(doc, expected_result['measure_id'], result_key)
      reported_results[key] = reported_result
      validation_errors.concat ProductTest.match_calculation_results(expected_result,reported_result)
    end

    te = self.test_executions.build(expected_results:self.expected_results,  reported_results: reported_results,
                                     matched_results: matched_results, execution_errors: validation_errors)
    te.artifact = Artifact.new(:file => qrda_file)

    (te.execution_errors.where({msg_type: :error}).count == 0) ? te.pass : te.failed

    te.save
    te
  end





  def generate_qrda_cat1_test

    self.measures.top_level.each do |mes|
      results = self.results.where({"value.measure_id" => mes.hqmf_id, "value.IPP" => {"$gt" => 0}})
      mrns = results.collect{|r| r["value"]["medical_record_id"]}
      results.uniq!
       qrda = QRDAProductTest.new(measure_ids: [mes.measure_id],
                               name: "#{self.name} - Measure #{mes.nqf_id} QRDA Cat I Test",
                               bundle_id: self.bundle_id,
                               effective_date: self.effective_date,
                               product_id: self.product_id,
                               user_id: self.user_id,
                               calculated_test_id: self.id)
        records = self.records.where({"medical_record_number" => {"$in"=>mrns}})

        records.each do |rec| 
          new_results = results.select { |res| res.value.patient_id == rec.id }
          new_rec = rec.dup
          new_rec[:test_id] = qrda.id 
          new_rec.save

          new_results.each do |res|
            res_clone = Result.new()
            res_clone["value"] = res["value"].clone
            res_clone["value"]["test_id"]=qrda.id
            res_clone["value"]["patient_id"] = new_rec.id
            res_clone.save
          end 
        end

       qrda.save
       qrda.ready

    end

    self[:qrda_generated] = true
    self.save
  end




  def self.product_type_measures(bundle)
    bundle.measures.top_level_by_type("ep") #.where({"population_ids.MSRPOPL" => {"$exists" => false}})
  end


end
