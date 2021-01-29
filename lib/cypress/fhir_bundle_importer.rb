require 'cqm-parsers'

module Cypress
  class FHIRBundleImporter
    SOURCE_ROOTS = { bundle: 'bundle.json',
                     measures: 'measures',
                     patients: 'patients' }.freeze

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
        raise bundle.errors.full_messages.join(',') unless check_measure_years(bundle)
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
        measure_bundle = MeasureBundle.new
        measure_bundle.measure_bundle_hash = JSON.parse(measure_file.get_input_stream.read, max_nesting: 100)
        bundle.fhir_measure_bundles << measure_bundle
        report_progress('measures', (index * 100 / measure_files.length)) if (index % 10).zero?
      end
      bundle.save!
      puts "\rLoading: Measures Complete          "
    end

    def self.unpack_and_store_patients(zip, bundle)
      patient_files = zip.glob(File.join(SOURCE_ROOTS[:patients], '**', '*.json'))
      patient_files.each_with_index do |patient_file, index|
        patient_bundle = PatientBundle.new
        patient_bundle.patient_bundle_hash = JSON.parse(patient_file.get_input_stream.read, max_nesting: 100)
        bundle.fhir_patient_bundles << patient_bundle
        report_progress('patients', (index * 100 / patient_files.length)) if (index % 10).zero?
      end
      bundle.save!
      puts "\rLoading: Patients Complete          "
    end

    def self.report_progress(label, percent)
      print "\rLoading: #{label} #{percent}% complete"
      STDOUT.flush
    end

    def self.check_measure_years(bundle)
      # individual measure periods must match full bundle period
      # TODO: compares dates because the FHIR does not go to a detailed datetime specification
      checks = true
      bundle.fhir_measure_bundles.each do |fmb|
        measure_string = "Measure #{fmb.name} version #{fmb.version} period"
        bundle_start = Time.at(bundle.measure_period_start).in_time_zone.to_date
        bundle_end = Time.at(bundle.effective_date).in_time_zone.to_date
        measure_start = Date.strptime(fmb.effectivePeriod.start, "%Y-%m-%d")
        measure_end = Date.strptime(fmb.effectivePeriod.end, "%Y-%m-%d")
        if measure_start != bundle_start
          checks = false
          raise "#{measure_string} start #{measure_start} does not match bundle period start #{bundle_start}"
        end
        if measure_end != bundle_end
          checks = false
          raise "#{measure_string} end #{measure_end} does not match bundle period end #{bundle_end}"
        end
      end
      checks
    end

  end
end
