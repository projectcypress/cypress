module Cypress
  class MeasureEvaluator
    # Evaluates the supplied measure for a particular vendor
    def self.eval(vendor, measure)
      report = QME::QualityReport.new(measure['id'], measure.sub_id, 
        {'effective_date'=>vendor.effective_date, 'test_id'=>vendor.id})
      result = {'numerator' => '?', 'denominator' => '?', 'exclusions' => '?'}
      if report.calculated?
        result = report.result
      elsif Resque::Status.get(vendor.patient_gen_job).completed?
        report.calculate
      end
      result['measure_id'] = measure.id.to_s
      result['key'] = measure.key
      result
    end
  end
end