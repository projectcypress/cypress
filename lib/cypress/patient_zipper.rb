# frozen_string_literal: true

require 'builder'
require 'csv'
require 'open-uri'

require 'zip/zip'
require 'zip/zipfilesystem'

module Cypress
  class HTMLExporter
    # TODO: add HTML Export in CQM-Parsers
    # EXPORTER = HealthDataStandards::Export::HTML.new
    attr_accessor :measures

    def initialize(measures, start_time, end_time)
      # TODO: conversion will not be needed, QDM -> HTML
      # @qdm_patient_converter = CQM::Converter::QDMPatient.new
      @measures = measures.to_a
      @start_time = start_time
      @end_time = end_time
    end

    def export(patient)
      QdmPatient.new(patient, true).render
    end
  end

  class QRDAExporter
    attr_accessor :measures, :start_time, :end_time

    def initialize(measures, start_time, end_time)
      @measures = measures
      @start_time = start_time
      @end_time = end_time
    end

    # rubocop:disable Metrics/PerceivedComplexity
    def export(patient)
      cat1_program = if (patient.product_test&.product&.c3_test || patient.product_test&.product&.cvuplus) && patient.product_test&.eh_measures?
                       patient.product_test&.submission_program
                     else
                       false
                     end
      options = { provider: patient.providers.first,
                  patient_addresses: patient.addresses,
                  patient_telecoms: patient.telecoms,
                  patient_email: patient.email,
                  medicare_beneficiary_identifier: patient.medicare_beneficiary_identifier,
                  submission_program: cat1_program,
                  ry2026_submission: patient.product_test&.bundle&.major_version == '2025',
                  start_time:, end_time: }
      Qrda1R5.new(patient, measures, options).render
    end
    # rubocop:enable Metrics/PerceivedComplexity
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
          sf_patient.id = patient.id
          # CMS529 requires that entries point to the ecounters that they are related to
          sf_patient.add_encounter_ids_to_events if measures.map(&:hqmf_id).intersect?(APP_CONSTANTS['result_measures'].map(&:hqmf_id))
          patient_scoop_and_filter.scoop_and_filter(sf_patient)
          z.put_next_entry("#{next_entry_path(patient, i)}.#{FORMAT_EXTENSIONS[format.to_sym]}")
          z << formatter.export(sf_patient)
        end
      end
    end

    def self.apply_sort_to(patients)
      patients.sort_by { |p| "#{p.givenNames.join('_')}_#{p.familyName}" }
    end

    def self.measure_start_end(patients)
      return unless patients.first

      first = patients.first
      ptest = first.product_test
      measures = if ptest
                   ptest.measures.only(:id, :population_sets, :cms_id, :description, :hqmf_id, :hqmf_set_id, :value_set_ids, :source_data_criteria)
                 else
                   patients.first.bundle.measures.only(:id, :population_sets, :cms_id, :description, :hqmf_id, :hqmf_set_id,
                                                       :value_set_ids, :source_data_criteria).limit(1)
                 end
      start_date = ptest ? ptest.start_date : Time.at(patients.first.bundle.measure_period_start).in_time_zone
      end_date = ptest ? ptest.end_date : start_date + 1.year - 1.second
      [measures, start_date, end_date]
    end

    def self.next_entry_path(patient, index)
      safe_first_name = patient.givenNames.join(' ').delete("'")
      safe_last_name = patient.familyName.delete("'")
      "#{index}_#{safe_first_name}_#{safe_last_name}"
    end
  end
end
