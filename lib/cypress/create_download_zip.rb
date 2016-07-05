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
      file = Tempfile.new("combined-report-#{Time.now.to_i}")
      Zip::ZipOutputStream.open(file.path) do |z|
        add_file_to_zip(z, 'product_report.html', report_content)

        product.product_tests.each do |m|
          next if m.is_a?(ChecklistTest)
          filter_folder = m.is_a?(FilteringTest) ? '/' + m.name_slug : ''

          folder_name = "#{m._type.underscore.dasherize}s/#{m.cms_id}#{filter_folder}"

          add_file_to_zip(z, "#{folder_name}/records/#{m.cms_id}_#{m.id}.qrda.zip", m.patient_archive.read)

          m.tasks.each do |t|
            most_recent_execution = t.most_recent_execution
            if most_recent_execution
              mre_filename = "#{folder_name}/uploads/#{most_recent_execution.artifact.file.uploaded_filename}"
              add_file_to_zip(z, mre_filename, most_recent_execution.artifact.file.read)
            end
          end
        end
      end
      file
    end

    def self.add_file_to_zip(z, file_name, file_content)
      z.put_next_entry(file_name)
      z << file_content
    end
  end
end
