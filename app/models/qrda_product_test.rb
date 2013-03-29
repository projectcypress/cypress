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
puts "execute"
    if file.content_type == 'application/zip'
      errors = []
      Zip::ZipFile.open(file.path) do |zipfile|
        puts "zip open"
        zipfile.entries.each do |entry|
          data = zipfile.read(entry.name)
          File.open(File.join(te.file_root,entry.name), "w") { |io| io.puts data.force_encoding("UTF-8") }
          puts "process entry #{entry.name}"
          
          errs = Cypress::QrdaUtility.validate_cat_1(data, measures, entry.name)
          errs.each {|e| e[:file_name]=entry.name}
          errors.concat errs
        end
        
      end
      te.execution_errors = errors
      # ids = Cypress::ArtifactManager.save_artifacts(file,te)
      # te.file_ids = ids
      FileUtils.cp(file.path, File.join(te.file_root, "UPLOAD")) 
    else

      te.execution_errors = Cypress::QrdaUtility.validate_cat_1(file.open.read, measures, file.original_filename)
      FileUtils.cp(file.path, File.join(te.file_root, "UPLOAD")) 
    end
    te.uploaded_file = file
    te.save


     # calculate the measures based off of the imported patients 

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