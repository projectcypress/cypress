class Record

  include Mongoid::Document

  field :first, type: String
  field :last, type: String
  field :gender, type: String
  field :birthdate, type: Integer
  field :test_id, type: BSON::ObjectId

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
        xml.ExactDateTime(convert_to_ccr_time_string(Time.now))
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
        to_ccr_results(xml)
        to_ccr_encounters(xml)
        #to_ccr_medications(xml)
        #to_ccr_immunizations(xml)
        #to_ccr_medical_equipments(xml)
        #to_ccr_social_histories(xml)
        to_ccr_procedures(xml)
        #to_ccr_allergies(xml)
        #to_ccr_care_goals(xml)
      end
      to_ccr_actors(xml)
    end
  end

  private

  # Builds the XML snippet for the problems section inside the CCR standard
  #
  # @return [Builder::XmlMarkup] CCR XML representation of patient data
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
              xml.ExactDateTime(convert_to_ccr_time_string(condition.time))
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

  # Builds the XML snippet for the encounters section inside the CCR standard
  #
  # @return [Builder::XmlMarkup] CCR XML representation of patient data
  def to_ccr_encounters(xml = nil)
    xml ||= Builder::XmlMarkup.new(:indent => 2)
    if (!encounters.nil? && !encounters.empty?)
      xml.Encounters do
        encounters.each_with_index do |encounter, index|
          xml.Encounter do
            xml.CCRDataObjectID("EN000" + (index+1).to_s)
            xml.DateTime do
              xml.Type do
                xml.Text("Encounter Date")
              end
              #time
              xml.ExactDateTime(convert_to_ccr_time_string(encounter.time))
            end
            xml.Description do
              xml.Text(encounter.description)
              xml.Code do
                if (!encounter.codes.nil? && !encounter.codes.empty?)
                  encounter.codes.each_pair do |code_set, coded_values|
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

  # Builds the XML snippet for the vitals section inside the CCR standard
  #
  # @return [Builder::XmlMarkup] CCR XML representation of patient data
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
              xml.ExactDateTime(convert_to_ccr_time_string(vital_sign.time))
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

  # Builds the XML snippet for the lab section inside the CCR standard
  #
  # @return [Builder::XmlMarkup] CCR XML representation of patient data
  def to_ccr_results(xml = nil)
    xml ||= Builder::XmlMarkup.new(:indent => 2)
    if (!results.nil? && !results.empty?)
      xml.Results do
        results.each_with_index do |lab_result, index|
          xml.Result do
            xml.CCRDataObjectID("LB000" + (index+1).to_s)
            xml.DateTime do
              xml.Type do
                xml.Text("Start date")
              end
              #time
              xml.ExactDateTime(convert_to_ccr_time_string(lab_result.time))
            end
            xml.Description do
              xml.Text(lab_result.description)
              if (!lab_result.codes.nil? && !lab_result.codes.empty?)
                lab_result.codes.each_pair do |code_set, coded_values|
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

  # Builds the XML snippet for the procedures section inside the CCR standard
  #
  # @return [Builder::XmlMarkup] CCR XML representation of patient data
  def to_ccr_procedures(xml = nil)
    xml ||= Builder::XmlMarkup.new(:indent => 2)
    if (!procedures.nil? && !procedures.empty?)
      xml.Procedures do
        procedures.each_with_index do |procedure, index|
          xml.Procedure do
            xml.CCRDataObjectID("PR000" + (index+1).to_s)
            xml.DateTime do
              xml.Type do
                xml.Text("Service date")
              end
              #time
              xml.ExactDateTime(convert_to_ccr_time_string(procedure.time))
            end
            xml.Description do
              xml.Text(procedure.description)
              if (!procedure.codes.nil? && !procedure.codes.empty?)
                procedure.codes.each_pair do |code_set, coded_values|
                  xml.Code do
                    coded_values.each do |coded_value|
                      xml.Value(coded_value)
                      xml.CodingSystem(code_set)
                      #TODO: Need to fix this and not be a hard-coded value
                      xml.Version("2008")
                    end
                  end
                end
              end
            end
            xml.Status do
              xml.Text("Active")
            end
          end
        end
      end
    end
  end

  # Builds the XML snippet for a actors section inside the CCR standard
  #
  # @return [Builder::XmlMarkup] CCR XML representation of patient data
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
          xml.ExactDateTime(convert_to_ccr_time_string(birthdate))
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
  # @return [Builder::XmlMarkup] CCR XML representation of patient data
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

  def convert_to_ccr_time_string(time)
    converted_time = Time.at(time)
    converted_time.strftime("%Y-%m-%dT%H:%M:%SZ")
  end

end