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
      records = bundle.patients
      %w[html qrda].each do |format|
        extensions = { html: 'html', qrda: 'xml' }
        formatter = formatter_for_patients(records, format)
        FileUtils.mkdir_p(File.join(path, "#{format}_records/"))
        records.each do |r|
          filename = "#{format}_records/#{r.first_names}_#{r.familyName}.#{extensions[format.to_sym]}".delete("'").tr(' ', '_')
          File.open(File.join(path, filename), 'w') do |f|
            f.write(formatter.export(r))
          end
        end
      end
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
      file = Tempfile.new("c1_sample_criteria-#{Time.now.to_i}.zip")
      # Archive records checks whether the archive has already been created and creates
      # it if it has not.
      c1_patient_zip = checklist_test.archive_patients
      Zip::ZipOutputStream.open(file.path) do |output_zip|
        # Copy contents of existing c1_patient_zip into output file
        Zip::InputStream.open(c1_patient_zip.path) do |patient_archive|
          while (entry = patient_archive.get_next_entry)
            add_file_to_zip(output_zip, entry.name, patient_archive.read)
          end
        end
        # Add criteria_list to zip
        add_file_to_zip(output_zip, 'criteria_list.html', criteria_list)
      end
      file
    end

    # The intent of this is to break the create c1 criteria zip out into 2 parts and pre-package
    # the patients so that even if a measure is deprecated and the patient cache is deleted
    # the user will still be able to Download All Patients and View Record Samples.
    # It would be good to merge these back together when rails 5 comes out since rails 5
    # supports calls to render outside of the controller.
    def self.create_c1_patient_zip(checklist_test)
      file = Tempfile.new("c1_sample_patients-#{Time.now.to_i}.zip")
      example_patients = {}
      checklist_test.measures.each do |m|
        example_patients[m.cms_id] = Cypress::ExamplePatientFinder.find_example_patient(m)
      end
      formatter = formatter_for_patients(example_patients.values, 'html')
      Zip::ZipOutputStream.open(file.path) do |z|
        example_patients.each do |measure_id, patient|
          # TODO: R2P: format patients for export
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
      mes, sd, ed = Cypress::PatientZipper.measure_start_end(records)
      if format == 'html'
        formatter = Cypress::HTMLExporter.new(mes, sd, ed)
      elsif format == 'qrda'
        formatter = Cypress::QRDAExporter.new(mes, sd, ed)
      end
      formatter
    end
  end
end
