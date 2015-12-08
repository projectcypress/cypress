class PatientArchiveJob < ActiveJob::Base
  queue_as :patient_archive
  
  def perform(product_test)
    file = Tempfile.new("product_test-#{product_test.id}.zip")
    Cypress::PatientZipper.zip(file, product_test.records, :qrda)
    product_test.patient_archive = file
    product_test.save
  end

end