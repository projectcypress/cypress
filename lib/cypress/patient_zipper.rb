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

    FORMAT_EXTENSIONS = {html: "html", qrda: "xml"}
    FORMATERS = {:html => HealthDataStandards::Export::HTML.new}


    def self.zip_artifacts(test_execution)
      execution_path = File.join("tmp", "te-#{test_execution.id}")
      zip_path = File.join(execution_path, "#{Time.now.to_i}")
      FileUtils.mkdir_p(zip_path)
      records = test_execution.product_test.records
      records_path = File.join(zip_path, "records")
      write_patients(test_execution.product_test, records_path)
      
      pdf_generator = Cypress::PdfGenerator.new(test_execution)
      pdf = pdf_generator.generate(zip_path)


      if  test_execution.artifact
        name = test_execution.artifact.file.uploaded_filename
        path  = test_execution.artifact.file.path
 
        # copy to ziup path 
        FileUtils.copy(path, zip_path)
        # vendor_uploaded_results = test_execution.artifact.file.force_encoding("UTF-8")
        # File.open(File.join(zip_path, "vendor-uploaded-results.xml"), "w") {|file| file.write(vendor_uploaded_results)}
      end 

      Zip::ZipFile.open("#{zip_path}.zip", Zip::ZipFile::CREATE) do |zip|
        Dir[File.join(records_path, "**", "**")].each do |file|
          filename = file.slice(/records.*/)
          zip.add(filename, file)
        end
        zip.add("test-execution-results.pdf", pdf)
        if  test_execution.artifact
            zip.add(test_execution.artifact.file.uploaded_filename, File.join(zip_path, test_execution.artifact.file.uploaded_filename))
        end
      end

      # Move the zip to a tempfile so the system will delete it for us. Then delete the temporary record directory we made.
      zip = Tempfile.new("te-#{test_execution.id}")
      zip.write(File.read("#{zip_path}.zip"))
      zip.close
      FileUtils.rm_r execution_path
      
      zip
    end

    def self.write_patients(test_execution, path)
      ["json", "html", "qrda"].each do |format|
        FileUtils.mkdir_p File.join(path, format)
      end
      start_date = test_execution.start_date
      end_date = test_execution.end_date
      measures = test_execution.measures.top_level.to_a
      qrda_exporter = Cypress::QRDAExporter.new(measures,start_date,end_date)
      html_exporter = Cypress::HTMLExporter.new(measures,start_date,end_date)
      test_execution.records.each do |patient|
        safe_first_name = patient.first.gsub("'", "")
        safe_last_name = patient.last.gsub("'", "")   
        filename ="#{safe_first_name}_#{safe_last_name}"
        json = JSON.pretty_generate(JSON.parse(patient.as_json(:except => [ '_id','measure_id' ]).to_json))

        html = html_exporter.export(patient)
        qrda =  qrda_exporter.export(patient)
        File.open(File.join(path, "html", "#{filename}.html"), "w") {|file| file.write(html)}
        File.open(File.join(path, "json", "#{filename}.json"), "w") {|file| file.write(json)}
        File.open(File.join(path, "qrda", "#{filename}.xml"), "w") {|file| file.write(qrda)}
      end
    
  end

    def self.zip(file, patients, format)
      
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
      if format.to_sym == :qrda  
        formater = Cypress::QRDAExporter.new(measures,start_date,end_date)
      else
        formater = Cypress::HTMLExporter.new(measures,start_date,end_date)
      end

      Zip::ZipOutputStream.open(file.path) do |z|
        patients.each_with_index do |patient, i|
          safe_first_name = patient.first.gsub("'", '')
          safe_last_name = patient.last.gsub("'", '')
          next_entry_path = "#{i}_#{safe_first_name}_#{safe_last_name}"       
          z.put_next_entry("#{next_entry_path}.#{FORMAT_EXTENSIONS[format.to_sym]}") 
          if formater == HealthDataStandards::Export::HTML
            z << formater.new.export(patient)
          else
            z << formater.export(patient)
          end
        end
      end
    end

  end

end

