namespace :bundle do
  task setup: :environment

  desc %(
    Upload precalculate bundle file with extension .zip
  )
  task :precalculate_bundle, [:file] => :setup do |_, args|
    bundle = Cypress::CqlBundleImporter.import(File.new(args.file), Tracker.new, true)
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
      zip.remove('calculations/measure-id-mapping.csv') if zip.find_entry('calculations/measure-id-mapping.csv')
      zip.remove('calculations/patient-id-mapping.csv') if zip.find_entry('calculations/patient-id-mapping.csv')
      zip.remove('calculations/individual-results') if zip.find_entry('calculations/individual-results')
      zip.add('calculations/measure-id-mapping.csv', measure_id_mapping)
      zip.add('calculations/patient-id-mapping.csv', patient_id_mapping)
      bundle.results.each_with_index do |result, index|
        individual_result_file = Tempfile.new("individual-result-#{index}.json")
        individual_result_file.write(result.to_json)
        zip.add("calculations/individual-results/individual-result-#{index}.json", individual_result_file)
      end
    end
    bundle.destroy
  end
end
