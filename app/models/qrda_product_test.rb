class QRDAProductTest < ProductTest
  after_create :generate_population
  
  def generate_population
    self.status_message = "Generating patient record"
    self.save
    Delayed::Job.enqueue(Cypress::QRDAGenerationJob.new({"test_id" =>  self.id.to_s}))
  end
  
  def execute(params)

    file = params[:results]
    te = self.test_executions.build(expected_results: self.expected_results, execution_date: Time.now.to_i)
    te.execution_errors = Cypress::QrdaUtility.validate_cat_1(file.open.read, measures, "results")
    ids = Cypress::ArtifactManager.save_artifacts(file,te)
    te.file_ids = ids
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