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

  # Builds a CCR XML document representing the patient.
  #
  # @return [Builder::XmlMarkup] CCR XML representation of patient data
  def to_ccr(xml = nil)
    xml ||= Builder::XmlMarkup.new(:indent => 2)
    xml.ContinuityOfCareRecord("xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                               "xsi:schemaLocation" => "urn:astm-org:CCR CCR_20051109.xsd http://www.w3.org/2001/XMLSchema xmldsig-core-schema.xsd",
                               "xmlns" => "urn:astm-org:CCR") do
      xml.CCRDocumentObjectID(id)
      xml.Language do
        xml.Text("English")
      end
      xml.Version("V1.0")
      xml.DateTime do
        #TODO: Need to fix this and not be a hard-coded value
        xml.ExactDateTime("2010-02-01T15:52:04Z")
        xml.ExactDateTime("2010-02-01T15:52:04Z")
      end
      xml.Patient do 
        xml.ActorID(id)
      end
      xml.From do
        xml.ActorLink do
          xml.ActorID("AA0002")
        end
      end
      to_ccr_purpose(xml)
      xml.body do
        to_ccr_problems(xml)
        to_ccr_vitals(xml)
        #to_ccr_results(xml)
        #to_ccr_encounters(xml)
        #to_ccr_medications(xml)
        #to_ccr_immunizations(xml)
        #to_ccr_medical_equipments(xml)
        #to_ccr_social_histories(xml)
        #to_ccr_procedures(xml)
        #to_ccr_allergies(xml)
        #to_ccr_care_goals(xml)
      end
      to_ccr_actors(xml)
    end
  end

  # Builds a C32 XML document representing the patient.
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

  private

  # Builds the XML snippet for a problems section inside the CCR standard
  #
  # @return [Builder::XmlMarkup] C32 XML representation of patient data
  def to_ccr_problems(xml = nil)
    xml ||= Builder::XmlMarkup.new(:indent => 2)
    if (!conditions.nil? && !conditions.empty?)
      xml.Problems do
        conditions.each_with_index do |condition, index|
          xml.Problem do
            xml.CCRDataObjectID("PR000" + (index+1).to_s)
            xml.DateTime do
              xml.Type do
                xml.Text("Start date")
              end
              #time
              xml.ExactDateTime("1990-08-07T06:00:00Z")
            end
            xml.Type do
              #TODO: Need to fix this and not be a hard-coded value
              xml.Text("Diagnosis")
            end
            xml.Description do
              xml.Text(condition.description)
              xml.Code do
                if (!condition.codes.nil? && !condition.codes.empty?)
                  condition.codes.each_pair do |code_set, coded_values|
                    coded_values.each do |coded_value|
                      xml.Value(coded_value)
                      xml.CodingSystem(code_set)
                      #TODO: Need to fix this and not be a hard-coded value
                      xml.Version("2005")
                    end
                  end
                end
              end
            end
            xml.Status do
              xml.Text("Active")
            end
            xml.Source do
              xml.Actor do
                xml.ActorID(id)
              end
            end
          end
        end
      end
    end
  end

  # Builds the XML snippet for a problems section inside the CCR standard
  #
  # @return [Builder::XmlMarkup] C32 XML representation of patient data
  def to_ccr_vitals(xml = nil)
    xml ||= Builder::XmlMarkup.new(:indent => 2)
    if (!vital_signs.nil? && !vital_signs.empty?)
      xml.VitalSigns do
        vital_signs.each_with_index do |vital_sign, index|
          xml.Result do
            xml.CCRDataObjectID("VT000" + (index+1).to_s)
            xml.DateTime do
              xml.Type do
                xml.Text("Start date")
              end
              #time
              xml.ExactDateTime("1990-08-07T06:00:00Z")
            end
            xml.Description do
              xml.Text(vital_sign.description)
              if (!vital_sign.codes.nil? && !vital_sign.codes.empty?)
                vital_sign.codes.each_pair do |code_set, coded_values|
                  xml.Code do
                    coded_values.each do |coded_value|
                      xml.Value(coded_value)
                      xml.CodingSystem(code_set)
                      #TODO: Need to fix this and not be a hard-coded value
                      xml.Version("2005")
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  # Builds the XML snippet for a actors section inside the CCR standard
  #
  # @return [Builder::XmlMarkup] C32 XML representation of patient data
  def to_ccr_actors(xml = nil)
    xml ||= Builder::XmlMarkup.new(:indent => 2)
    xml.Actors do
      xml.Actor do
        xml.ActorObjectID("AA0001")
        xml.Person do
          xml.Name do
            xml.CurrentName do
              xml.Given(first)
              xml.Family(last)
            end
          end
        end
        xml.DateOfBirth do
          xml.ExactDateTime("1960-08-19T06:00:00Z")
            if (gender)
            xml.Gender do
              if (gender.upcase == "M")
                xml.Text("Male")
              elsif (gender.upcase == "F")
                xml.Text("Female")
              else
                xml.Text("Undifferentiated")
              end
            end
          end
        end
      end
    end
  end

  # Builds the XML snippet for a purpose section inside the CCR standard
  #
  # @return [Builder::XmlMarkup] C32 XML representation of patient data
  def to_ccr_purpose(xml = nil)
    xml ||= Builder::XmlMarkup.new(:indent => 2)
    xml.Purpose do
      xml.Description do
        xml.Text("Cypress Test Patient CCR XML Record")
      end
      xml.Indications do
        xml.Indication do
          xml.Source do
            xml.Actor do
              xml.ActorID("AA0002")
            end
          end
          xml.InternalCCRLink do
            xml.LinkID
          end
        end
      end
    end
  end

end