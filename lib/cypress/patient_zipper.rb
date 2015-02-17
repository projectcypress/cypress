require 'builder'
require 'csv'
require 'open-uri'

require 'zip/zip'
require 'zip/zipfilesystem'

module Cypress

  class HTMLExporter
    EXPORTER = HealthDataStandards::Export::HTML.new
    attr_accessor :measures

    def initialize(measures,start_time,end_time)
      @measures = measures.to_a
      @start_time = start_time
      @end_time = end_time
    end

    def export(patient)
    EXPORTER.export(patient,measures)
    end

  end

  class QRDAExporter
    EXPORTER  = HealthDataStandards::Export::Cat1.new
    attr_accessor :measures
    attr_accessor :start_time
    attr_accessor :end_time

    def initialize(measures,start_time,end_time)
      @measures = measures.to_a
      @start_time = start_time
      @end_time = end_time
    end

    def export(patient)

    EXPORTER.export(patient,measures,start_time,end_time)
    end

  end

  HTML_EXPORTER = HealthDataStandards::Export::HTML.new

  class PatientZipper

    FORMAT_EXTENSIONS = {html: "html", qrda: "xml", json: "json"}

    def self.zip_artifacts(test_execution)
      execution_path = File.join("tmp", "te-#{test_execution.id}")
      zip_path = File.join(execution_path, "#{Time.now.to_i}")
      FileUtils.mkdir_p(zip_path)
      rec_path = File.join(zip_path, "records")

      self.write_patients(test_execution.product_test, rec_path)

      pdf = Cypress::PdfGenerator.new(test_execution).generate(zip_path)

      self.copy_artifact(test_execution.artifact.file, zip_path) if test_execution.artifact

      self.create_artifact_zip(test_execution, zip_path, rec_path, pdf)

      # Move the zip to a tempfile so the system will delete it for us.
      # Then delete the temporary record directory we made.
      zip = Tempfile.new("te-#{test_execution.id}")
      zip.write(File.read("#{zip_path}.zip"))
      zip.close
      FileUtils.rm_r execution_path

      zip
    end

    def self.zip(file, patients, format)
      mes, sd, ed = set_mes_start_end(patients)

      if format.to_sym == :qrda
        formatter = Cypress::QRDAExporter.new(mes,sd,ed)
      else
        formatter = Cypress::HTMLExporter.new(mes,sd,ed)
      end

      Zip::ZipOutputStream.open(file.path) do |z|
        patients.each_with_index do |patient, i|
          safe_first_name = patient.first.gsub("'", '')
          safe_last_name = patient.last.gsub("'", '')
          next_entry_path = "#{i}_#{safe_first_name}_#{safe_last_name}"
          z.put_next_entry("#{next_entry_path}.#{FORMAT_EXTENSIONS[format.to_sym]}")
          if formatter == HealthDataStandards::Export::HTML
            z << formatter.new.export(patient)
          else
            z << formatter.export(patient)
          end
        end
      end
    end

    private

    def self.set_mes_start_end(patients)
      if patients.first
        test = ProductTest.where({"_id" => patients.first["test_id"]}).first
        if test
          measures = test.measures.top_level.to_a
          start_date = test.start_date
          end_time = test.end_date
        end
      end
      measures ||= Measure.top_level
      end_date ||= Time.at(patients.first.bundle.effective_date).gmtime
      start_date ||= end_date.years_ago(1)
      return measures, start_date, end_date
    end

    def self.create_artifact_zip(test_execution, zip_path, records_path, pdf)
      Zip::ZipFile.open("#{zip_path}.zip", Zip::ZipFile::CREATE) do |zip|
        Dir[File.join(records_path, "**", "**")].each do |file|
          filename = file.slice(/records.*/)
          zip.add(filename, file)
        end
        zip.add("test-execution-results.pdf", pdf)
        if  test_execution.artifact
            zip_filename = test_execution.artifact.file.uploaded_filename
            zip.add(zip_filename, File.join(zip_path, zip_filename))
        end
      end
    end

    def self.copy_artifact(file, zip_path)
      name = file.uploaded_filename
      path = file.path

      # copy to zip path
      FileUtils.copy(path, zip_path)
    end

    def self.write_patients(product_test, path)
      ["json", "html", "qrda"].each do |format|
        FileUtils.mkdir_p File.join(path, format)
      end
      start_date = product_test.start_date
      end_date = product_test.end_date
      measures = product_test.measures.top_level.to_a
      qrda_exporter = Cypress::QRDAExporter.new(measures,start_date,end_date)
      html_exporter = Cypress::HTMLExporter.new(measures,start_date,end_date)
      product_test.records.each do |patient|
        export_patient(patient, path, qrda_exporter, html_exporter)
      end
    end

    def self.export_patient(patient, path, qrda_exporter, html_exporter)
      safe_first_name = patient.first.gsub("'", "")
      safe_last_name = patient.last.gsub("'", "")
      filename ="#{safe_first_name}_#{safe_last_name}"
      json = JSON.pretty_generate(JSON.parse(patient.as_json(:except => [ '_id','measure_id' ]).to_json))

      html = html_exporter.export(patient)
      qrda =  qrda_exporter.export(patient)
      write_file(path, filename, html, "html")
      write_file(path, filename, qrda, "qrda")
      write_file(path, filename, json, "json")
    end

    def self.write_file(path, filename, exporter, type)
      File.open(File.join(path, type, "#{filename}.#{FORMAT_EXTENSIONS[type.to_sym]}"), "w") {|file| file.write(exporter)}
    end

  end

end
