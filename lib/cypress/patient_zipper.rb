require 'builder'
require 'csv'
require 'open-uri'

require 'zip/zip'
require 'zip/zipfilesystem'

module Cypress


  class QRDAExporter

    attr_accessor :measures
    attr_accessor :start_time
    attr_accessor :end_time

    def initialize(measures,start_time,end_time)
      @measures = measures.to_a
      @start_time = start_time
      @end_time = end_time
    end


    def export(patient)
       puts "exporting patient"
       QrdaGenerator::Export::Cat1.export(patient,measures,start_time,end_time)
    end

  end


 
  class PatientZipper

    FORMAT_EXTENSIONS = {html: "html", qrda: "xml"}
    FORMATERS = {:html => HealthDataStandards::Export::HTML}


    def self.zip_artifacts(test_execution)
      execution_path = File.join("tmp", "te-#{test_execution.id}")
      zip_path = File.join(execution_path, "#{Time.now.to_i}")

      records = test_execution.product_test.records
      records_path = File.join(zip_path, "records")
      write_patients(test_execution.product_test, records_path)
      
      pdf_generator = Cypress::PdfGenerator.new(test_execution)
      pdf = pdf_generator.generate(zip_path)


      if  test_execution.files.length >0 
        vendor_uploaded_results = test_execution.files[0].data.force_encoding("UTF-8")
        File.open(File.join(zip_path, "vendor-uploaded-results.xml"), "w") {|file| file.write(vendor_uploaded_results)}
      end 

      Zip::ZipFile.open("#{zip_path}.zip", Zip::ZipFile::CREATE) do |zip|
        Dir[File.join(records_path, "**", "**")].each do |file|
          filename = file.slice(/records.*/)
          zip.add(filename, file)
        end
        zip.add("test-execution-results.pdf", pdf)
        if  test_execution.files.length >0 
          zip.add("vendor-uploaded-results.xml", File.join(zip_path, "vendor-uploaded-results.xml"))
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
      measures = test_execution.measures.to_a
      qrda_exporter = Cypress::QRDAExporter.new(measures,start_date,end_date)
      test_execution.records.each do |patient|
        filename = TPG::Exporter.patient_filename(patient)
        json = JSON.pretty_generate(JSON.parse(patient.as_json(:except => [ '_id','measure_id' ]).to_json))
        html = HealthDataStandards::Export::HTML.export(patient)
        qrda =  qrda_exporter.export(patient)
        File.open(File.join(path, "html", "#{filename}.html"), "w") {|file| file.write(html)}
        File.open(File.join(path, "json", "#{filename}.json"), "w") {|file| file.write(json)}
        File.open(File.join(path, "qrda", "#{filename}.xml"), "w") {|file| file.write(qrda)}
      end
    
  end

    def self.zip(file, patients, format)
      if format.to_sym == :qrda
        if patients.first
          test = ProductTest.where({"_id" => patients.first["test_id"]}).first
          if test 
            measures = test.measures.to_a
            start_time = test.start_date
            end_time = test.end_date
          end
        end
        measures ||= Measure.top_level
        end_date ||= Time.at(Cypress::MeasureEvaluator::STATIC_EFFECTIVE_DATE).gmtime
        start_date ||= end_date.years_ago(1)
        formater = Cypress::QRDAExporter.new(measures,start_date,end_date)
      else
        formater = FORMATERS[format.to_sym]
      end

      Zip::ZipOutputStream.open(file.path) do |z|
        patients.each_with_index do |patient, i|
          safe_first_name = patient.first.gsub("'", '')
          safe_last_name = patient.last.gsub("'", '')
          next_entry_path = "#{i}_#{safe_first_name}_#{safe_last_name}"       
          z.put_next_entry("#{next_entry_path}.#{FORMAT_EXTENSIONS[format.to_sym]}") 
          z << formater.export(patient)
        end
      end
    end

  end

end