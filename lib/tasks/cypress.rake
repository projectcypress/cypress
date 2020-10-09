namespace :cypress do
  namespace :cleanup do
    task setup: :environment

    desc 'Remove temporary items (such as vendors, tests, etc) from the database, without removing existing users'
    task database: :setup do
      print 'Cleaning database...'
      Delayed::Job.destroy_all
      before = Vendor.all.count
      Vendor.destroy_all
      diff = before - Vendor.all.count
      Record.destroy_all(test_id: { '$ne' => nil })
      Artifact.destroy_all
      puts "removed #{diff} Vendors"
    end

    desc 'Get rid of files in tmp/cache'
    task temp_files: :setup do
      print 'Cleaning temp files...'
      task('tmp:cache:clear').invoke
      Rails.cache.clear
      puts 'done'
    end

    task all: %i[environment database temp_files]
  end
  # Usage: bundle exec rake cypress:recalculate:product_tests[5ed687f566105e4e3b9737a0]
  namespace :recalculate do
    task setup: :environment

    desc 'Recalculate test deck for provided product.  This will delete the calculations made during the ProductTestSetupJob'
    task :product_tests, %i[product_id] => :setup do |_, args|
      product_tests = ProductTest.where(product_id: args.product_id)
      product_tests.each do |pt|
        # Remove prior calcuations (if they are there)
        IndividualResult.where(correlation_id: pt.id.to_s).delete
        pt.expected_results = nil
        pt.save
        results = ProductTestSetupJob.new.calculate_product_test(pt)
        MeasureEvaluationJob.perform_now(pt, individual_results: results)
      end
    end
  end

  namespace :import do
    task :config, %i[config_file environment] => :environment do |_, args|
      if File.exist?(args.config_file)
        # Get rid of the first and last quote on the string, split on all spaces
        # This loads "AUTO_APPROVE=true" "ENABLE_DEBUG_FEATURES="... into the environment
        unless args.environment.nil?
          args.environment[1..-2].split('" "').each do |key_val|
            key_val_split = key_val.split('=')
            # If the value is nil then convert it to empty string in order to satisfy previous setup
            ENV[key_val_split[0]] = (key_val_split[1] || '')
          end
        end
        # Get all of the keys from the Settings model
        settings_keys = Settings.fields.keys
        # Fetch and parse the contents of the yaml config file
        yaml_content = YAML.safe_load(ERB.new(File.read(args.config_file)).result)
        # Filter the yaml content to only contain the keys we store in the database
        yaml_content.select! { |key, _| settings_keys.include? key }
        # Save those keys in the database.
        Settings.current.update(yaml_content)
      end
    end

    task descriptions: :setup do
      description_hash = {}

      start = Time.new.in_time_zone
      Patient.where(_type: { '$in': ['CQM::BundlePatient', 'CQM::VendorPatient'] }).each do |p|
        # pull out codes by exporting and re-importing
        if p.code_description_hash.empty?
          @options = { start_time: Date.new(2012, 1, 1), end_time: Date.new(2012, 12, 31) }
          patient_xml = Qrda1R5.new(p, Measure.where(hqmf_id: Measure.first.hqmf_id), @options).render # measure is arbitrary placeholder
          doc = Nokogiri::XML::Document.parse(patient_xml)
          doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
          doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
          _patient, _warnings, codes = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)

          # build code descriptions for original patient
          Cypress::QRDAPostProcessor.build_code_descriptions(codes, p, p.bundle)

          p.save
        end
        description_hash[p.id] = p.code_description_hash
      end
      print "#{Patient.not_in(_type: CQM::ProductTestPatient).all.count} patients were updated in #{Time.new.in_time_zone - start} seconds\n"

      start = Time.new.in_time_zone
      CQM::ProductTestPatient.each do |ptp|
        next unless ptp.code_description_hash.empty?

        ptp.code_description_hash = description_hash[ptp.original_patient_id]
        Cypress::DemographicsRandomizer.update_demographic_codes(ptp)
        ptp.save
      end
      print "#{CQM::ProductTestPatient.all.count} patients were updated in #{Time.new.in_time_zone - start} seconds\n"
    end
  end
end
