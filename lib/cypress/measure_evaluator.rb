module Cypress
  
  class  MeasureEvaluationJob

    attr_reader :options

    def initialize(options)
      @options = options
    end
    
    def perform
 
       t = CalculatedProductTest.find(options["test_id"])

       results = {}
       measure_count = t.measures.length

       t.measures.each_with_index do |measure,index|

        dictionary = Cypress::MeasureEvaluator.generate_oid_dictionary(measure, t.bundle)
        qr = QME::QualityReport.new(measure["hqmf_id"], measure.sub_id, 'effective_date' => t.effective_date,
                                     'test_id' => t.id, 'filters' => options['filters'], "oid_dictionary"=>dictionary,
                                     'enable_logging' => true , "enable_rationale" =>true, 'bundle_id' => t.bundle.id)
        t.status_message = " Calculating measure #{index} of #{measure_count} - #{measure.display_name}"
        t.save
        qr.calculate(false) 
        result = qr.result
        result.delete("_id")
        results[measure.key] = result
       end
       t.expected_results = results
       t.status_message = "Measures Calculated"
       t.save
       t.ready
    end
    
  end
  
  class MeasureEvaluator

    STATIC_EFFECTIVE_DATE = Time.gm(APP_CONFIG["effective_date"]["year"],
                                    APP_CONFIG["effective_date"]["month"],
                                    APP_CONFIG["effective_date"]["day"]).to_i
  
    # Evaluates the supplied measure for a particular vendor
    def self.eval(test, measure, asynchronous = true)
      dictionary = Cypress::MeasureEvaluator.generate_oid_dictionary(measure, test.bundle)
      qr = QME::QualityReport.new(measure["hqmf_id"], measure.sub_id, 'effective_date' => test.effective_date, 'test_id' => test.id, 'filters' =>nil, "oid_dictionary"=>dictionary, 'bundle_id' => test.bundle.id)

      qr.calculate(false) 
      result = qr.result
      result.delete("_id")
      result

    end

    # Evaluates the supplied measure for the static patients
    def self.eval_for_static_records(measure, asynchronous = true)
      report = QME::QualityReport.new(measure['hqmf_id'], measure.sub_id, 
        {'effective_date' => Bundle.find(measure.bundle_id).effective_date, 'test_id' => nil})
      result = {'NUMER' => '?', 'DENOM' => '?', 'DENEX' => '?'}
      
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


    def self.generate_oid_dictionary(measure, bundle)
      valuesets = bundle.value_sets.in({oid: measure.oids})
      js = {}
      valuesets.each do |vs|
        js[vs.oid] ||= {}
        vs.concepts.each do |con|
          name = con.code_system_name
          js[vs.oid][name] ||= []
          js[vs.oid][name] << con.code.downcase  unless js[vs.oid][name].index(con.code.downcase)
        end
      end

      js.to_json
    end

  end
end