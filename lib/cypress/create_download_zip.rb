module Cypress
  class CreateDownloadZip
    def self.create_test_zip(test_id, format = 'html')
      pt = ProductTest.find(test_id)
      create_zip(pt.records.to_a, format)
    end

    def self.create_zip(patients, format)
      file = Tempfile.new("patients-#{Time.now.to_i}")
      Cypress::PatientZipper.zip(file, patients, format)
      file
    end

    def self.create_total_test_zip(product, format = 'qrda')
      measure_tests = MeasureTest.where(product_id: product.id)
      file = Tempfile.new("all-patients-#{Time.now.to_i}")
      Zip::ZipOutputStream.open(file.path) do |z|
        measure_tests.each do |m|
          z.put_next_entry("#{m.cms_id}_#{m.id}.#{format}.zip".tr(' ', '_'))
          z << m.patient_archive.read
        end
      end
      file
    end

    def self.create_combined_report_zip(product, report_content)
      measure_tests = MeasureTest.where(product_id: product.id)
      file = Tempfile.new("combined-report-#{Time.now.to_i}")
      Zip::ZipOutputStream.open(file.path) do |z|
        z.put_next_entry('product_report.html')
        z << report_content

        measure_tests.each do |m|
          z.put_next_entry("#{m.cms_id}/#{m.cms_id}_#{m.id}_records.qrda.zip".tr(' ', '_'))
          z << m.patient_archive.read

          # most recent test executions

          m.tasks.each do |t|
            most_recent_execution = t.most_recent_execution
            if most_recent_execution
              z.put_next_entry("#{m.cms_id}/#{most_recent_execution.artifact.file.uploaded_filename}")
              z << most_recent_execution.artifact.file.read
            end
          end
        end
      end
      file
    end
  end
end
