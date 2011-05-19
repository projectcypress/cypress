class Record
  include Mongoid::Document
  
  field :first, type: String
  field :last, type: String
  field :gender, type: String
  field :birthdate, type: Integer
  
  [:allergies, :care_goals, :conditions, :encounters, :immunizations, :medical_equipment,
   :medications, :procedures, :results, :social_history, :vital_signs].each do |section|
    embeds_many section, as: :entry_list, class_name: "Entry"
  end

  # Build a CCR XML document representing the patient.
  #
  # @return [Builder::XmlMarkup] CCR XML representation of patient data
  def to_ccr(xml = nil)
    xml ||= Builder::XmlMarkup.new(:indent => 2)
    xml.ContinuityOfCareRecord("xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                               "xsi:schemaLocation" => "urn:astm-org:CCR CCR_20051109.xsd http://www.w3.org/2001/XMLSchema xmldsig-core-schema.xsd",
                               "xmlns" => "urn:astm-org:CCR") do
      xml.CCRDocumentObjectID(id)
      allergies.each do |allergy|
        xml.allergy("some allergy")
      end
      results.each do |result|
        xml.result("some result")
      end
      care_goals.each do |care_goal|
        xml.care_goal("some care_goal")
      end
      vital_signs.each do |vital_sign|
        xml.vital_sign("some vital_sign")
      end 
      encounters.each do |encounter|
        xml.encounter("some encounter")
      end
      conditions.each do |condition|
        xml.condition("some condition")
      end
      procedures.each do |procedure|
        xml.procedure("some procedure")
      end
      medications.each do |medication|
        xml.medication("some medication")
      end
    end
  end

  # Build a C32 XML document representing the patient.
  #
  # @return [Builder::XmlMarkup] C32 XML representation of patient data
  def to_c32(xml = nil)
    xml ||= Builder::XmlMarkup.new(:indent => 2)
    xml.ClinicalDocument("xsi:schemaLocation" => "urn:hl7-org:v3 http://xreg2.nist.gov:8080/hitspValidation/schema/cdar2c32/infrastructure/cda/C32_CDA.xsd",
                         "xmlns" => "urn:hl7-org:v3",
                         "xmlns:sdtc" => "urn:hl7-org:sdtc",
                         "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do
      xml.realmCode( "code" => "US" ) #C32 2.4
      xml.typeId("root" => "2.16.840.1.113883.1.3", "extension" => "POCD_HD000040")
      xml.templateId("root" => "2.16.840.1.113883.3.27.1776", "assigningAuthorityName" => "CDA/R2")
      xml.templateId("root" => "2.16.840.1.113883.10.20.1", "assigningAuthorityName" => "CCD")
      xml.templateId("root" => "2.16.840.1.113883.3.88.11.32.1", "assigningAuthorityName" => "HITSP/C32")
      xml.templateId("root" => "2.16.840.1.113883.10.20.3", "assigningAuthorityName" => "CCD")
      xml.templateId("root" => "1.3.6.1.4.1.19376.1.5.3.1.1.1")
      xml.id("root" => "2.16.840.1.113883.3.72", 
             "extension" => "Cypress C32 XML Patient Record",
             "assigningAuthorityName" => "Cypress: An Open Source EHR Quality Measure Testing Framework projectcypress.org")
      xml.code("code" => "34133-9",
               "displayName" => "Summarization of patient data", 
               "codeSystem" => "2.16.840.1.113883.6.1", 
               "codeSystemName" => "LOINC")
      xml.title("Cypress C32 Patient Test Record")
      #todo
      #if registration_information.try(:document_timestamp)
      #  xml.effectiveTime("value" => c32_timestamp(registration_information.document_timestamp))
      #else
      #  xml.effectiveTime("value" => c32_timestamp(updated_at))
      #end
      #xml.confidentialityCode
      xml.languageCode("code" => "en-US")
      #information_source.try(:to_c32, xml)
    end
  end

end