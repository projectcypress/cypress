module Cypress
  
  class  MeasureEvaluationJob

    attr_reader :options

    def initialize(options)
      @options = options
    end
    
    def perform
 
       t = CalculatedProductTest.find(options["test_id"])

       results = {}
       t.measures.each do |measure|

        dictionary = Cypress::MeasureEvaluator.generate_oid_dictionary(measure)
        qr = QME::QualityReport.new(measure["hqmf_id"], measure.sub_id, 'effective_date' => t.effective_date, 'test_id' => t.id, 'filters' => options['filters'], "oid_dictionary"=>dictionary)

        qr.calculate(false) 
        result = qr.result
        result.delete("_id")
        results[measure.key] = result
       end
       t.expected_results = results
       t.save
       t.ready
    end
    
  end
  
  class MeasureEvaluator

    CODE_SYSTEM_NAME_MAPPING = {
      "SNOMEDCT" => "SNOMED-CT",
         "ICD9CM" => "ICD-9-CM",
         "ICD10PCS" => "ICD-10-PCS",
         "ICD10CM" => "ICD-10-CM",
         "RXNORM"=>"RxNorm", 
         "CDCREC" => "CDC Race", 
         "HSLOC" => "HSLOC", 
         "SOP" => "SOP"
    }

    STATIC_EFFECTIVE_DATE = Time.gm(APP_CONFIG["effective_date"]["year"],
                                    APP_CONFIG["effective_date"]["month"],
                                    APP_CONFIG["effective_date"]["day"]).to_i
  
    # Evaluates the supplied measure for a particular vendor
    def self.eval(test, measure, asynchronous = true)
      report = QME::QualityReport.new(measure['hqmf_id'], measure.sub_id, 
        {'effective_date' => test.effective_date, 'test_id' => test.id.to_s})
      result = {'numerator' => '?', 'denominator' => '?', 'exclusions' => '?'}
      
      test.result_calculation_jobs = {} if test.result_calculation_jobs.nil?
      measure_id = measure.id.to_s
      
      if report.calculated?
        # Get rid of any resque jobs that we may have used to calculate these results and return the result
        test.result_calculation_jobs.delete(measure_id)
        result = report.result
      elsif asynchronous
        # If we don't already have an existing job for this measure, create one and add it to our job list
        job = test.result_calculation_jobs[measure_id]
        if job.nil?
          uuid = report.calculate()
          job   = report.status(uuid)
        end
        test.result_calculation_jobs[measure_id] = job
      else
        #The measure calculation job needs test.id to be a string,which it converts to an objectID
        #Giving it a straight objectID causes an error. Thus we call calculate on newreport, and the result is stored in the original report!
       
        newreport = QME::QualityReport.new(measure['hqmf_id'], measure.sub_id, 
        {'effective_date' => test.effective_date, 'test_id' => test.id.to_s})
        newreport.calculate(false)
      
        result = report.result
      end
      test.save!
      
      result['measure_id'] = measure.id.to_s
      result['key'] = measure.key
      
      return result
    end

    # Evaluates the supplied measure for the static patients
    def self.eval_for_static_records(measure, asynchronous = true)
      report = QME::QualityReport.new(measure['hqmf_id'], measure.sub_id, 
        {'effective_date' => STATIC_EFFECTIVE_DATE, 'test_id' => nil})
      result = {'numerator' => '?', 'denominator' => '?', 'exclusions' => '?'}
      
      if report.calculated?
        result = report.result
      else 
        report.calculate(asynchronous)
        if !asynchronous
          result = report.result
        end
      end
      result['measure_id'] = measure.id.to_s
      result['key'] = measure.key
      
      return result
    end


    def self.generate_oid_dictionary(measure)
      valuesets = HealthDataStandards::SVS::ValueSet.in({oid: measure.oids})
      js = {}
      valuesets.each do |vs|
        js[vs.oid] ||= {}
        vs.concepts.each do |con|
          name = normailize_name(con)
          js[vs.oid][name] ||= []
          js[vs.oid][name] << con.code.downcase  unless js[vs.oid][name].index(con.code.downcase)
        end
      end

      js.to_json
    end

    def self.normailize_name(code)
      name = nil
      if code.code_system
        name = HealthDataStandards::Util::CodeSystemHelper.code_system_for(code.code_system)
      end
      if name.nil? && HealthDataStandards::Util::CodeSystemHelper.oid_for_code_system(code.code_system_name)
        name = code.code_system_name
      end

      if name.nil?
        name = CODE_SYSTEM_NAME_MAPPING[code.code_system_name] || code.code_system_name
      end
      name
   end

  end
end