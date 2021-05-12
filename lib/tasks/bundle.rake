# frozen_string_literal: true

namespace :bundle do
  task setup: :environment

  desc %(
    Upload precalculate bundle file with extension .zip
  )
  task :precalculate_bundle, [:file] => :setup do |_, args|
    bundle = Cypress::CqlBundleImporter.import(File.new(args.file), Tracker.new, include_highlighting: true)
    measure_id_mapping = Tempfile.new('measure-id-mapping.csv')
    CSV.open(measure_id_mapping, 'w') do |csv|
      bundle.measures.each do |measure|
        csv << [measure.id.to_s, measure.cms_id]
      end
    end
    patient_id_mapping = Tempfile.new('patient-id-mapping.csv')
    CSV.open(patient_id_mapping, 'w') do |csv|
      bundle.patients.each do |patient|
        csv << [patient.id.to_s, patient.givenNames[0], patient.familyName]
      end
    end
    Zip::File.open(args.file, Zip::File::CREATE) do |zip|
      if zip.find_entry('calculations/measure-id-mapping.csv')
        puts 'Bundle already has calculations'
        break
      end
      zip.add('calculations/measure-id-mapping.csv', measure_id_mapping)
      zip.add('calculations/patient-id-mapping.csv', patient_id_mapping)
      bundle.results.each_with_index do |result, index|
        individual_result_file = Tempfile.new("individual-result-#{index}.json")
        individual_result_file.write(result.to_json)
        zip.add("calculations/individual-results/individual-result-#{index}.json", individual_result_file)
        individual_result_file.close
      end
    end
    measure_id_mapping.close
    patient_id_mapping.close
    bundle.destroy
  end

  task :test_dcab, [:cms_id] => :setup do |_, args|
    measure = Measure.where(cms_id: args.cms_id).first
    measure.source_data_criteria.each do |sdc|
      sdc.dataElementAttributes = []
    end
    measure.save
    dcab = Cypress::DataCriteriaAttributeBuilder.new
    dcab.build_data_criteria_for_measure(measure)
  end
end
