module Cypress
  
  class  MeasureEvaluationJob < Resque::JobWithStatus
    
    def perform
       t = CalculatedProductTest.find(options["test_id"])

       results = {}
       t.measures.each do |measure|
           qr = QME::QualityReport.new(measure["hqmf_id"], measure.sub_id, 'effective_date' => t.effective_date, 'test_id' => t.id.to_s, 'filters' => options['filters'])
           result = nil
           if qr.calculated?
             result=qr.result
             completed("#{options['measure_id']}#{options['sub_id']} has already been calculated") if respond_to? :completed
           else
             map = QME::MapReduce::Executor.new(measure["hqmf_id"], measure.sub_id, 'effective_date' => t.effective_date, 'test_id' => t.id.to_s, 'filters' => options['filters'], 'start_time' => Time.now.to_i)

             if !qr.patients_cached?           
               map.map_records_into_measure_groups
             end
             result = map.count_records_in_measure_groups
           end
          
         result = qr.result
         result['measure_id'] = measure.id.to_s
         result['key'] = measure.key
         results[measure.id.to_s] = result
       end
       
       t.expected_results = results
       t.save
       t.ready
    end
    
  end
  
  class MeasureEvaluator
    STATIC_EFFECTIVE_DATE = Time.new(APP_CONFIG["effective_date"]["year"],
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
  end
end