class QRDAProductTest < ProductTest
  after_create :generate_population
  
  def generate_population
    self.status_message = "Generating patient record"
    self.save
    Delayed::Job.enqueue(Cypress::QRDAGenerationJob.new({"test_id" =>  self.id.to_s}))
  end
  
  def execute(params)
    te = self.test_executions.build(expected_results: self.expected_results, execution_date: Time.now.to_i) 
    te.save
    file = params[:results]
    artifact = Artifact.new(:file=> file, test_execution: te)
    artifact.save
    validation_errors = []
    artifact.each_file do |name, data|
      errs = Cypress::QrdaUtility.validate_cat_1(data, measures, name)
      errs.each {|e| e[:file_name]=name}
      validation_errors.concat errs
    end
    te.execution_errors = validation_errors
    te.artifact = artifact
    te.save
    (te.count_errors > 0) ? te.failed : te.pass
    te
  end

  def measures
    return [] if !measure_ids
    self.bundle.measures.in(:hqmf_id => measure_ids).top_level.order_by([[:hqmf_id, :asc],[:sub_id, :asc]])
  end
  
  
  def self.product_type_measures(bundle)
    bundle.measures.top_level
  end
end