namespace :bundle do
  task setup: :environment
  
  desc %(
    Upload measure bundle file with extension .zip
  )
  task :upload_bundle, [:file] => :setup do |_, args|
    bundle_file = args.file
    bundle_name = bundle_file.split("/").last()
    unless File.extname(bundle_name) == '.zip'
      puts 'Bundle file must have extension .zip'
      return
    end

    FileUtils.mkdir_p(APP_CONSTANTS['bundle_file_path'])
    file_name = "bundle_#{rand(Time.now.to_i)}.zip"
    file_path = File.join(APP_CONSTANTS['bundle_file_path'], file_name)
    FileUtils.mv(bundle_file, file_path)
    BundleUploadJob.perform_later(file_path, bundle_name)
    puts "Uploading #{bundle_name} bundle"
  end

  desc %(
    Upload measure bundle file with extension .zip
  )
  task :precalculate_bundle, [:file] => :setup do |_, args|
    bundle = Cypress::CqlBundleImporter.import(File.new(args.file), Tracker.new, true)
    bundle.results.each_with_index do |result, index|
      File.open("tmp/individual-results/individual-result-#{index}.json","w") do |f|
        f.write(result.to_json)
      end
    end
    CSV.open("tmp/measure-id-mapping.csv", "w") do |csv|
      bundle.measures.each do |measure|
        csv << [measure.id.to_s, measure.cms_id]
      end
    end
    CSV.open("tmp/patient-id-mapping.csv", "w") do |csv|
      bundle.patients.each do |patient|
        csv << [patient.id.to_s, patient.givenNames[0], patient.familyName]
      end
    end
    bundle.destroy
  end
end
