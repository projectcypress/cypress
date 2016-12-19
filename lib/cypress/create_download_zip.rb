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

    def self.bundle_directory(bundle, path)
      records = bundle.records
      %w(html qrda).each do |format|
        extensions = { html: 'html', qrda: 'xml' }
        formatter = formatter_for_patients(records, format)
        FileUtils.mkdir_p(File.join(path, "#{format}_records/"))
        records.each do |r|
          filename = "#{format}_records/#{r.first}_#{r.last}.#{extensions[format.to_sym]}".delete("'").tr(' ', '_')
          File.open(File.join(path, filename), 'w') do |f|
            f.write(formatter.export(r))
          end
        end
      end
    end

    def self.create_total_test_zip(product, criteria_list, format = 'qrda')
      file = Tempfile.new("all-patients-#{Time.now.to_i}")
      Zip::ZipOutputStream.open(file.path) do |z|
        add_measure_zips(z, product.product_tests.measure_tests, format)
        add_checklist_zips(z, product.product_tests.checklist_tests, criteria_list)
        add_filtering_zips(z, product.product_tests.filtering_tests, format) unless product.product_tests.filtering_tests.empty?
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

    def self.export_log_files
      file = Tempfile.new("application_logs-#{Time.now.to_i}.zip")
      Zip::ZipOutputStream.open(file.path) do |z|
        Dir.glob('*/*.log') do |log_file|
          add_file_to_zip(z, log_file, IO.read(log_file))
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

    def self.add_measure_zips(z, measure_tests, format)
      measure_tests.each do |pt|
        add_file_to_zip(z, "#{pt.cms_id}_#{pt.id}.#{format}.zip".tr(' ', '_'), pt.patient_archive.read)
      end
    end

    def self.add_checklist_zips(z, checklist_tests, criteria_list)
      checklist_tests.each do |pt|
        p = pt.product
        file = Cypress::CreateDownloadZip.create_c1_criteria_zip(p.product_tests.checklist_tests.first, criteria_list).read
        add_file_to_zip(z, "checklisttest_#{p.name}_#{p.id}_c1_manual_criteria.zip".tr(' ', '_'), file)
      end
    end

    def self.add_filtering_zips(z, filtering_tests, format)
      pt = filtering_tests.first
      add_file_to_zip(z, "filteringtest_#{pt.cms_id}_#{pt.id}.#{format}.zip".tr(' ', '_'), pt.patient_archive.read)
    end
  end
end
