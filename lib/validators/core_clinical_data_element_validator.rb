# frozen_string_literal: true

module Validators
  class CoreClinicalDataElementValidator < QrdaFileValidator
    include Validators::Validator
    include QrdaHelper

    def initialize(measures)
      @test_measure_ids = measures.pluck(:hqmf_id)
    end

    def validate(file, options = {})
      ccde_measure_ids = APP_CONSTANTS['result_measures'].map(&:hqmf_id)
      @ccde_measure_ids = options.task.bundle.measures.where('hqmf_id' => { '$in' => ccde_measure_ids }).pluck(:hqmf_id)
      return unless ccde_measure_ids.intersect?(@test_measure_ids)

      doc = get_document(file)
      case options.task._type
      when 'CmsProgramTask'
        verify_patient_ids(doc, options)
        verify_ccde_program(doc, options)
      when 'C3Cat1Task'
        verify_patient_ids(doc, options)
      end
      verify_only_ccde_measures(doc, options)
      verify_encounters(doc, options)
    end

    def verify_patient_ids(doc, options)
      # As of 2022 this is no longer required
      return unless options.task.bundle.major_version.to_i < 2022

      reported_id = doc.at_xpath('//cda:recordTarget/cda:patientRole/cda:id[@root="2.16.840.1.113883.4.927"]')
      reported_id ||= doc.at_xpath('//cda:recordTarget/cda:patientRole/cda:id[@root="2.16.840.1.113883.4.572"]')
      return if reported_id

      msg = 'CMS_0084 - QRDA files for hybrid measure/CCDE submissions must contain a HICN or MBI.'
      add_error(msg, file_name: options[:file_name])
    end

    def verify_ccde_program(doc, options)
      prog = doc.at_xpath('//cda:informationRecipient/cda:intendedRecipient/cda:id/@extension')
      # Prior to 2022 the program was HQR_IQR_VOL, now its HQR_IQR
      required_program = options.task.bundle.major_version.to_i < 2022 ? 'HQR_IQR_VOL' : 'HQR_IQR'
      return if prog.value == required_program

      msg = "CMS_0085 - CMS program name for hybrid measure/CCDE submissions must be #{required_program}."
      add_error(msg, file_name: options[:file_name])
    end

    def verify_only_ccde_measures(doc, options)
      reported_measure_ids = measure_ids_from_cat_1_file(doc)
      return if (reported_measure_ids - @ccde_measure_ids).empty?

      msg = 'CMS_0086 - Files containing hybrid measure/CCDE submissions and eCQM cannot be submitted within the same batch'
      add_error(msg, file_name: options[:file_name])
    end

    def verify_encounters(doc, options)
      encounter_ids = encounter_ids_in_doc(doc)
      # Get Entries related to Core Clinical Data Element (Laboraty Test, Performed (V5) and Physical Exam, Performed (V5)
      ccde_xpath = %(//cda:entry/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.38'
                   or @root='2.16.840.1.113883.10.20.24.3.59']])
      # The related to id is nested within the template
      related_id_xpath = %(./sdtc:inFulfillmentOf1[./sdtc:templateId[@root='2.16.840.1.113883.10.20.24.3.150']]/sdtc:actReference/sdtc:id)
      doc.xpath(ccde_xpath).each do |ccde|
        # The ID of the entry
        ccde_id = ccde.at_xpath('./cda:id')
        # string value entry id for use in error message
        ccde_id_string = "#{ccde_id['root']}(root), #{ccde_id['extension']}(extension)"
        # find the "related to" ID for the entry
        related_to_id = ccde.at_xpath(related_id_xpath)
        # If a related to ID can be found, make sure it points to an encounter in the file
        # If a related to ID cannot be found, return an error message
        if related_to_id
          # string value of the related to id for use in error message
          related_to_id_string = "#{related_to_id['root']}(root), #{related_to_id['extension']}(extension)"
          msg = "Referenced Encounter for Core Clinical Data Element entry #{ccde_id_string} cannot be found"
          add_error(msg, file_name: options[:file_name], location: ccde.path) unless encounter_ids.include?(related_to_id_string)
        else
          msg = "Encounter Reference missing for Core Clinical Data Element entry #{ccde_id_string}"
          add_warning(msg, file_name: options[:file_name], location: ccde.path)
        end
      end
    end

    # Return a list of encounter ids found in document
    def encounter_ids_in_doc(doc)
      encounter_ids = []
      encounter_ids_xpath = %(//cda:encounter[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.23']]/cda:id)
      doc.xpath(encounter_ids_xpath).each do |encounter_id|
        encounter_ids << "#{encounter_id['root']}(root), #{encounter_id['extension']}(extension)"
      end
      encounter_ids
    end
  end
end
