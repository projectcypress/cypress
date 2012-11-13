require 'builder'
require 'csv'
require 'open-uri'

require 'zip/zip'
require 'zip/zipfilesystem'

module Cypress
  class PatientZipper
    def self.zip_artifacts(test_execution)
      te_path = File.join("tmp", "te-#{test_execution.id}")
      zip_path = File.join(te_path, "#{Time.now.to_i}")

      records = test_execution.product_test.records
      records_path = File.join(zip_path, "records")
      write_patients(records, records_path)
      pdf = Cypress::PdfGenerator.generate_for(test_execution, zip_path)

      Zip::ZipFile.open("#{zip_path}.zip", Zip::ZipFile::CREATE) do |zip|
        Dir[File.join(records_path, "**", "**")].each do |file|
          filename = file.slice(/records.*/)
          zip.add(filename, file)
        end
        zip.add("results.pdf", pdf)
      end

      # Move the zip to a tempfile so the system will delete it for us. Then delete the temporary record directory we made.
      zip = Tempfile.new("te-#{test_execution.id}")
      zip.write(File.read("#{zip_path}.zip"))
      zip.close
      FileUtils.rm_r te_path
      
      zip
    end

    def self.write_patients(patients, path)
      ["c32", "ccda", "ccr", "json", "html"].each do |format|
        FileUtils.mkdir_p File.join(path, format)
      end

      patients.each do |patient|
        filename = TPG::Exporter.patient_filename(patient)
        c32 = HealthDataStandards::Export::C32.export(patient)
        ccda = HealthDataStandards::Export::CCDA.export(patient)
        ccr = HealthDataStandards::Export::CCR.export(patient)
        json = JSON.pretty_generate(JSON.parse(patient.as_json(:except => [ '_id', 'measure_id' ]).to_json))
        html = HealthDataStandards::Export::HTML.export(patient)

        File.open(File.join(path, "c32", "#{filename}.xml"), "w") {|file| file.write(c32)}
        File.open(File.join(path, "ccda", "#{filename}.xml"), "w") {|file| file.write(ccda)}
        File.open(File.join(path, "ccr", "#{filename}.xml"), "w") {|file| file.write(ccr)}
        File.open(File.join(path, "json", "#{filename}.json"), "w") {|file| file.write(json)}
        File.open(File.join(path, "html", "#{filename}.html"), "w") {|file| file.write(html)}
      end
    end

    def self.zip(file, patients, format)
      Zip::ZipOutputStream.open(file.path) do |z|
        xslt  = Nokogiri::XSLT(File.read(Rails.root.join("public","cda.xsl")))
        patients.each_with_index do |patient, i|
          safe_first_name = patient.first.gsub("'", '')
          safe_last_name = patient.last.gsub("'", '')
          next_entry_path = "#{i}_#{safe_first_name}_#{safe_last_name}"
        
          if format==:c32
            z.put_next_entry("#{next_entry_path}.xml")
            z << HealthDataStandards::Export::C32.export(patient)
          elsif format==:html
            #http://iweb.dl.sourceforge.net/project/ccr-resources/ccr-xslt-html/CCR%20XSL%20V2.0/ccr.xsl
             z.put_next_entry("#{next_entry_path}.html")
             z << HealthDataStandards::Export::HTML.export(patient)
            
          else
            z.put_next_entry("#{next_entry_path}.xml")
            z << HealthDataStandards::Export::CCR.export(patient)
          end
        end
      end
    end
    
    def self.flat_file(file, patients)
      CSV.open(file.path, "wb") do |csv|
       patients.each_with_index do |patient, i|
       if i < 1
        headerAndRow =HealthDataStandards::Export::CommaSV.export(patient,true)
        csv << headerAndRow[0]
        csv << headerAndRow[1]
       else
        csv << HealthDataStandards::Export::CommaSV.export(patient,false)
       end
      end
     end
    end    
  end
end