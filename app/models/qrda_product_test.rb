class QRDAProductTest < ProductTest
  after_create :generate_population
  
  def generate_population
    self.status_message = "Generating patient record"
    self.save
    Delayed::Job.enqueue(Cypress::QRDAGenerationJob.new({"test_id" =>  self.id.to_s}))
  end
  
  def execute(params)
    te = nil 
    file = params[:results]

    if file.content_type == 'application/zip'
      errors = []
      Zip::ZipFile.open(file.path) do |zipfile|
        zipfile.entries.each do |entry|
          te = self.test_executions.build(expected_results: self.expected_results, execution_date: Time.now.to_i)
          errs = Cypress::QrdaUtility.validate_cat_1(zipfile.read(entry.name), measures, entry.name)
          errs.each {|e| e[:file_name]=entry.name}
          errors.concat errs
        end
      end
      te.execution_errors = errors
      ids = Cypress::ArtifactManager.save_artifacts(file,te)
      te.file_ids = ids
    else
      te.execution_errors = Cypress::QrdaUtility.validate_cat_1(file.open.read, measures, file.original_file_name)
      ids = Cypress::ArtifactManager.save_artifacts(file,te)
      te.file_ids = ids
    end
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