module Cypress
  class CreateDownloadZip
    def self.bundle_directory(bundle, path)
      patients = bundle.patients
      %w[html qrda].each do |format|
        extensions = { html: 'html', qrda: 'xml' }
        formatter = formatter_for_patients(patients, format)
        FileUtils.mkdir_p(File.join(path, "#{format}_records/"))
        patients.each do |r|
          filename = "#{format}_records/#{r.first_names}_#{r.familyName}.#{extensions[format.to_sym]}".delete("'").tr(' ', '_')
          File.open(File.join(path, filename), 'w') do |f|
            f.write(formatter.export(r))
          end
        end
      end
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

    def self.formatter_for_patients(patients, format)
      mes, sd, ed = Cypress::PatientZipper.measure_start_end(patients)
      if format == 'html'
        formatter = Cypress::HTMLExporter.new(mes, sd, ed)
      elsif format == 'qrda'
        formatter = Cypress::QRDAExporter.new(mes, sd, ed)
      end
      formatter
    end
  end
end
