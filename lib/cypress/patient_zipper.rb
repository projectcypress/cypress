require 'builder'
require 'csv'
require 'open-uri'

require 'zip/zip'
require 'zip/zipfilesystem'

module Cypress
  class HTMLExporter
    # TODO add HTML Export in CQM-Parsers
    # EXPORTER = HealthDataStandards::Export::HTML.new
    attr_accessor :measures

    def initialize(measures, start_time, end_time)
      # TODO conversion will not be needed, QDM -> HTML
      # @qdm_patient_converter = CQM::Converter::QDMPatient.new
      @measures = measures.to_a
      @start_time = start_time
      @end_time = end_time
    end

    def export(patient)
      # TODO add HTML Export in CQM-Parsers
      # TODO: R2P: make sure patient export works with HDS HTML exporter
      # hdsrecord = @qdm_patient_converter.to_hds(patient)
      # hdsrecord.bundle_id = patient.bundleId
      # EXPORTER.export(hdsrecord, measures)
      '<html xmlns:n1="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></html>'
    end
  end

  class QRDAExporter
    attr_accessor :measures
    attr_accessor :start_time
    attr_accessor :end_time

    def initialize(measures, start_time, end_time)
      @measures = measures
      @start_time = start_time
      @end_time = end_time
    end

    def export(patient)
      cms_compatibility = patient.product_test&.product&.c3_test
      options = { provider: patient.provider, submission_program: cms_compatibility, start_time: start_time, end_time: end_time }
      case patient.bundle.qrda_version
      when 'r5'
        Qrda1R5.new(patient, measures, options).render
      end
    end
  end

  class PatientZipper
    FORMAT_EXTENSIONS = { html: 'html', qrda: 'xml', json: 'json' }.freeze

    def self.zip(file, patients, format)
      patients = apply_sort_to patients
      measures, sd, ed = measure_start_end(patients)
      patient_scoop_and_filter = Cypress::ScoopAndFilter.new(measures)

      # TODO: R2P: make sure patient exporter works (use correct one)
      formatter = if format.to_sym == :qrda
                    Cypress::QRDAExporter.new(measures, sd, ed)
                  else
                    Cypress::HTMLExporter.new(measures, sd, ed)
                  end

      Zip::ZipOutputStream.open(file.path) do |z|
        patients.each_with_index do |patient, i|
          sf_patient = patient.clone
          patient_scoop_and_filter.scoop_and_filter(sf_patient)
          z.put_next_entry("#{next_entry_path(patient, i)}.#{FORMAT_EXTENSIONS[format.to_sym]}")
          # TODO: R2P: make sure using correct exporter
          z << if formatter == Cypress::HTMLExporter
                 formatter.new.export(patient)
               else
                 formatter.export(sf_patient)
               end
        end
      end
    end

    def self.apply_sort_to(patients)
      patients.sort_by { |p| p.givenNames.join('_') + '_' + p.familyName }
    end

    def self.zip_patients_all_measures(file, measure_tests)
      # TODO: R2P: check exporter
      Zip::ZipOutputStream.open(file.path) do |zip|
        measure_tests.each do |measure_test|
          patients = measure_test.patients.to_a
          measures, start_date, end_date = measure_start_end(patients)
          formatter = Cypress::QRDAExporter.new(measures, start_date, end_date)
          measure_folder = "patients_#{measure_test.cms_id}"

          patients.each_with_index do |patient, i|
            zip.put_next_entry("#{measure_folder}/#{next_entry_path(patient, i)}.xml")
            zip << formatter.export(patient)
          end
        end
      end
    end

    def self.measure_start_end(patients)
      return unless patients.first
      first = patients.first
      ptest = first.product_test
      measures = ptest ? ptest.measures.top_level : patients.first.bundle.measures.top_level
      start_date = ptest ? ptest.start_date : Time.at(patients.first.bundle.effective_date).in_time_zone
      end_date = ptest ? ptest.end_date : start_date + 1.year
      [measures, start_date, end_date]
    end

    def self.next_entry_path(patient, index)
      safe_first_name = patient.givenNames.join(' ').delete("'")
      safe_last_name = patient.familyName.delete("'")
      "#{index}_#{safe_first_name}_#{safe_last_name}"
    end
  end
end
