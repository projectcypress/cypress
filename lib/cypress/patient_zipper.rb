require 'builder'
require 'csv'
require 'open-uri'

require 'zip/zip'
require 'zip/zipfilesystem'

module Cypress
  class HTMLExporter
    EXPORTER = HealthDataStandards::Export::HTML.new
    attr_accessor :measures

    def initialize(measures, start_time, end_time)
      @measures = measures.to_a
      @start_time = start_time
      @end_time = end_time
    end

    def export(patient)
      EXPORTER.export(patient, measures)
    end
  end

  class QRDAExporter
    C3EXPORTER = HealthDataStandards::Export::Cat1.new('r3')
    C3_1EXPORTER = HealthDataStandards::Export::Cat1.new('r3_1')
    attr_accessor :measures
    attr_accessor :start_time
    attr_accessor :end_time

    def initialize(measures, start_time, end_time)
      @measures = measures.to_a
      @start_time = start_time
      @end_time = end_time
    end

    def export(patient)
      cms_compatible = true if patient.product_test && patient.product_test.product.c3_test
      case patient.bundle.qrda_version
      when 'r3'
        C3EXPORTER.export(patient, measures, start_time, end_time, nil, 'r3', cms_compatible)
      when 'r3_1'
        C3_1EXPORTER.export(patient, measures, start_time, end_time, nil, 'r3_1', cms_compatible)
      end
    end
  end

  HTML_EXPORTER = HealthDataStandards::Export::HTML.new

  class PatientZipper
    FORMAT_EXTENSIONS = { html: 'html', qrda: 'xml', json: 'json' }.freeze

    def self.zip(file, patients, format)
      patients = apply_sort_to patients
      mes, sd, ed = mes_start_end(patients)

      formatter = if format.to_sym == :qrda
                    Cypress::QRDAExporter.new(mes, sd, ed)
                  else
                    Cypress::HTMLExporter.new(mes, sd, ed)
                  end

      Zip::ZipOutputStream.open(file.path) do |z|
        patients.each_with_index do |patient, i|
          # safe_first_name = patient.first.delete("'")
          # safe_last_name = patient.last.delete("'")
          # next_entry_path = "#{i}_#{safe_first_name}_#{safe_last_name}"
          z.put_next_entry("#{next_entry_path(patient, i)}.#{FORMAT_EXTENSIONS[format.to_sym]}")
          z << if formatter == HealthDataStandards::Export::HTML
                 formatter.new.export(patient)
               else
                 formatter.export(patient)
               end
        end
      end
    end

    def self.apply_sort_to(patients)
      if patients.is_a? Array
        patients.sort_by { |p| p.first + '_' + p.last }
      else
        patients.order_by(:first.asc, :last.asc)
      end
    end

    def self.zip_patients_all_measures(file, measure_tests)
      Zip::ZipOutputStream.open(file.path) do |zip|
        measure_tests.each do |measure_test|
          patients = measure_test.records.to_a
          measures, start_date, end_date = mes_start_end(patients)
          formatter = Cypress::QRDAExporter.new(measures, start_date, end_date)
          measure_folder = "patients_#{measure_test.cms_id}"

          patients.each_with_index do |patient, i|
            zip.put_next_entry("#{measure_folder}/#{next_entry_path(patient, i)}.xml")
            zip << formatter.export(patient)
          end
        end
      end
    end

    def self.mes_start_end(patients)
      return unless patients.first
      first = patients.first
      ptest = first.product_test
      measures = ptest ? ptest.measures.top_level : patients.first.bundle.measures.top_level
      start_date = ptest ? ptest.start_date : Time.at(patients.first.bundle.effective_date).in_time_zone
      end_date = ptest ? ptest.end_date : start_date + 1.year
      [measures, start_date, end_date]
    end

    def self.next_entry_path(patient, index)
      safe_first_name = patient.first.delete("'")
      safe_last_name = patient.last.delete("'")
      "#{index}_#{safe_first_name}_#{safe_last_name}"
    end
  end
end
