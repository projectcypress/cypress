require 'cqm-parsers'

module Cypress
  class FHIRBundleImporter
    SOURCE_ROOTS = { bundle: 'bundle.json',
                     measures: 'measures', measures_info: 'measures-info.json',
                     calculations: 'calculations',
                     valuesets: File.join('value-sets', 'value-set-codes.csv'),
                     patients: 'patients' }.freeze
    COLLECTION_NAMES = ['bundles', 'records', 'measures', 'individual_results', 'system.js'].freeze
    DEFAULTS = { type: nil,
                 update_measures: true,
                 clear_collections: COLLECTION_NAMES }.freeze

    # Import a quality bundle into the database. This includes metadata, measures, test patients, supporting JS libraries, and expected results.
    #
    # @param [File] zip The bundle zip file.

    def self.import(zip, tracker, include_highlighting = false)
      bundle = nil
      Zip::ZipFile.open(zip.path) do |zip_file|
        bundle = unpack_bundle(zip_file)
        check_bundle_versions(bundle)

        # Store the bundle metadata.
        raise bundle.errors.full_messages.join(',') unless bundle.save

        puts 'bundle metadata unpacked...'
        unpack_and_store_measures(zip_file, bundle)
        unpack_and_store_patients(zip_file, bundle)
      end

      bundle
    ensure
      # If the bundle is nil or the bundle has never been saved then do not set done_importing or run save.
      if bundle&.created_at
        bundle.done_importing = true
        bundle.save
      end
    end

    def self.check_bundle_versions(bundle)
      bundle_versions = Hash[* Bundle.where(deprecated: false).collect { |b| [b.version, b.id] }.flatten]

      # no bundles before 2018 and no non-deprecated bundles with same year
      old_year_err = 'Please use bundles for year 2019 or later.'
      raise old_year_err if bundle.version[0..3].to_i < 2019

      same_year_err = "A non-deprecated bundle with year #{bundle.version[0..3]} already exists in the database. Please deprecate previous bundles."
      raise same_year_err unless bundle_versions.select { |vers, _id| vers[0..3] == bundle.version[0..3] }.empty?
    end

    def self.unpack_bundle(zip)
      Bundle.new(JSON.parse(zip.read(SOURCE_ROOTS[:bundle]), max_nesting: 100).except('measures', 'patients'))
    end

    def self.unpack_and_store_measures(zip, bundle)
      # measure_info = JSON.parse(zip.read(SOURCE_ROOTS[:measures_info]))
      measure_files = zip.glob(File.join(SOURCE_ROOTS[:measures], '**', '*.json'))
      measure_files.each_with_index do |measure_file, index|
        measure = JSON.parse(measure_file.get_input_stream.read, max_nesting: 100)
        bundle.fhir_measures << measure
        report_progress('measures', (index * 100 / measure_files.length)) if (index % 10).zero?
      end
      bundle.save!
      puts "\rLoading: Measures Complete          "
    end

    def self.unpack_and_store_patients(zip, bundle)
      patient_files = zip.glob(File.join(SOURCE_ROOTS[:patients], '**', '*.json'))
      patient_files.each_with_index do |patient_file, index|
        patient = JSON.parse(patient_file.get_input_stream.read, max_nesting: 100)
        bundle.fhir_patients << patient
        report_progress('patients', (index * 100 / patient_files.length)) if (index % 10).zero?
      end
      bundle.save!
      puts "\rLoading: Patients Complete          "
    end

    def self.report_progress(label, percent)
      print "\rLoading: #{label} #{percent}% complete"
      STDOUT.flush
    end
  end
end
