
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

  def execute(params)

    qrda_file = params
    data = qrda_file.open.read
    doc = Nokogiri::XML(data)

    validation_errors = []

    qrda_validator = ::Validators::QrdaCat3Validator.new(doc)

    validation_errors = qrda_validator.validate || []

    matched_results = {}
    reported_results = {}

    expected_results.each_pair do |key,expected_result|
      result_key = expected_result["population_ids"].dup

      reported_result, errors = qrda_validator.extract_results_by_ids(expected_result['measure_id'], result_key)
      reported_results[key] = reported_result
      validation_errors.concat match_calculation_results(expected_result,reported_result)
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

  private

  def match_calculation_results(expected_result, reported_result)
    validation_errors = []
    measure_id = expected_result["measure_id"]
    logger = -> (message, stratification) {
      validation_errors << ExecutionError.new(message: message, msg_type: :error, measure_id: measure_id,
                validator_type: :result_validation, stratification: stratification)
    }

    check_for_reported_results_population_ids(expected_result, reported_result, logger)
    return validation_errors if validation_errors.present?

    _ids = expected_result["population_ids"].dup
    # remove the stratification entry if its there, not needed to test against values
    stratification = _ids.delete("stratification")
    logger_with_stratification = -> (message) {logger.call(message, stratification)}
    _ids.keys.each do |pop_key|
      if expected_result[pop_key].present?
  check_population(expected_result, reported_result, pop_key, stratification, logger)

  # Check supplemental data elements
  ex_sup = (expected_result["supplemental_data"] || {})[pop_key]
  reported_sup  = (reported_result[:supplemental_data] || {})[pop_key]
  if stratification.nil? && ex_sup

    sup_keys = ex_sup.keys.reject(&:blank?)
    # check to see if we expect sup data and if they provide it a short circuit the rest of the testing
    # if they do not
    if sup_keys.length>0 && reported_sup.nil?
      err = "supplemental data for #{pop_key} not found expected  #{ex_sup}"
      logger_with_stratification.call(err)
    else
      # for each supplemental data item (RACE, ETHNICITY,PAYER,SEX)
      sup_keys.each do |sup_key|
        sup_value  = (ex_sup[sup_key] || {}).reject{|k,v| (k.blank? || v.blank? || v=="UNK")}
        reported_sup_value = reported_sup[sup_key]
        check_supplemental_data(sup_value, reported_sup_value, pop_key, sup_key, logger_with_stratification)
      end
    end
  end
      end
    end

    validation_errors
  end

  def check_for_reported_results_population_ids(expected_result, reported_result, logger)
    _ids = expected_result["population_ids"].dup
    if reported_result.nil? || reported_result.keys.length <= 1
      message = "Could not find entry for measure #{expected_result["measure_id"]} with the following population ids "
      message +=  _ids.inspect
      logger.call(message, _ids['stratification'])
    end
  end

  def check_population(expected_result, reported_result, pop_key, stratification, logger)
    # only add the error that they dont match if there was an actual result
    if !reported_result.empty? && !reported_result.has_key?(pop_key)
      message = "Could not find value"
      message += " for stratification #{stratification} " if stratification
      message += " for Population #{pop_key}"
      logger.call(message, stratification)
    elsif (expected_result[pop_key] != reported_result[pop_key]) && !reported_result.empty?
     err = "expected #{pop_key} #{_ids[pop_key]} value #{expected_result[pop_key]} does not match reported value #{reported_result[pop_key]}"
     logger.call(err, stratification)
    end
  end

  def check_supplemental_data(expected_supplemental_value, reported_supplemantal_value,
           population_key, supplemental_data_key, logger)
    if reported_supplemantal_value.nil?
      err = "supplemental data for #{population_key} #{supplemental_data_key} #{expected_supplemental_value} expected but was not found"
      logger.call(err)
    else
      expected_supplemental_value.each_pair do |code,value|
  if code != "UNK" && value != reported_supplemantal_value[code]
   err = "expected supplemental data for #{population_key} #{supplemental_data_key} #{code} value [#{value}] does not match reported supplemental data value [#{ reported_supplemantal_value[code]}]"
   logger.call(err)
  end
      end
      reported_supplemantal_value.each_pair do |code,value|
  if expected_supplemental_value[code].nil?
   err = "unexpected supplemental data for #{population_key} #{supplemental_data_key} #{code}"
   logger.call(err)
  end
      end
    end
  end



end
