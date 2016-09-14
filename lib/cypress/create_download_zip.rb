module Cypress
  class CreateDownloadZip
    include ChecklistTestsHelper
    def self.create_test_zip(test_id, format = 'html')
      pt = ProductTest.find(test_id)
      create_zip(pt.records.to_a, format)
    end

    def self.create_zip(patients, format)
      file = Tempfile.new("patients-#{Time.now.to_i}")
      Cypress::PatientZipper.zip(file, patients, format)
      file
    end

    def self.all_patients
      file = file = Tempfile.new("all-patients-#{Time.now.to_i}")
      Zip::ZipOutputStream.open(file.path) do |z|
        Bundle.each do |bundle|
          records = bundle.records
          %w(html qrda).each do |format|
            extensions = { html: 'html', qrda: 'xml' }
            formatter = formatter_for_patients(records, format)
            records.each do |r|
              filename = "#{bundle.title}/#{format}_records/#{r.first}_#{r.last}.#{extensions[format.to_sym]}".delete("'").tr(' ', '_')
              add_file_to_zip(z, filename, formatter.export(r))
            end
          end
        end
      end
      file
    end

    def self.create_total_test_zip(product, format = 'qrda')
      measure_tests = MeasureTest.where(product_id: product.id)
      file = Tempfile.new("all-patients-#{Time.now.to_i}")
      Zip::ZipOutputStream.open(file.path) do |z|
        measure_tests.each do |m|
          add_file_to_zip(z, "#{m.cms_id}_#{m.id}.#{format}.zip".tr(' ', '_'), m.patient_archive.read)
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

    def self.create_c1_criteria_zip(checklist_test, criteria_list)
      file = Tempfile.new("c1_sample_patients-#{Time.now.to_i}.zip")
      example_patients = {}
      checklist_test.measures.each do |m|
        example_patients[m.cms_id] = Cypress::ExamplePatientFinder.find_example_patient(m)
      end
      formatter = formatter_for_patients(example_patients.values, 'html')
      Zip::ZipOutputStream.open(file.path) do |z|
        add_file_to_zip(z, 'criteria_list.html', criteria_list)
        example_patients.each do |measure_id, patient|
          add_file_to_zip(z, "sample patient for #{measure_id}.html", formatter.export(patient))
        end
      end
      file
    end

    def self.add_file_to_zip(z, file_name, file_content)
      z.put_next_entry(file_name)
      z << file_content
    end

    def self.formatter_for_patients(records, format)
      mes, sd, ed = Cypress::PatientZipper.mes_start_end(records)
      if format == 'html'
        formatter = Cypress::HTMLExporter.new(mes, sd, ed)
      elsif format == 'qrda'
        formatter = Cypress::QRDAExporter.new(mes, sd, ed)
      end
      formatter
    end
  end
end
