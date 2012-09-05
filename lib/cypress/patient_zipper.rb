require 'builder'
require 'csv'
require 'open-uri'

module Cypress
  class PatientZipper

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
             doc = Nokogiri::XML::Document.parse(HealthDataStandards::Export::C32.export(patient))
             
             xml = xslt.apply_to(doc)
            
             html=HealthDataStandards::Export::HTML.export(patient)
             transformed = Nokogiri::HTML::Document.parse(xml)
             transformed.at_css('ul').after(html)
             
             z << transformed.to_html
            
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