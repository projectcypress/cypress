module Cypress
  class MeasureEvaluator
    STATIC_EFFECTIVE_DATE = Time.gm(APP_CONFIG["effective_date"]["year"],
                                    APP_CONFIG["effective_date"]["month"],
                                    APP_CONFIG["effective_date"]["day"])
  
    # Evaluates the supplied measure for a particular vendor
    def self.eval(test, measure, asynchronous = true)
      report = QME::QualityReport.new(measure['id'], measure.sub_id, 
        {'effective_date' => test.effective_date, 'test_id' => test.id})
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
        newreport = QME::QualityReport.new(measure['id'], measure.sub_id, 
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
      report = QME::QualityReport.new(measure['id'], measure.sub_id, 
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