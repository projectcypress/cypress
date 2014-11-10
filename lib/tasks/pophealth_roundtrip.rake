namespace :pophealth_roundtrip do

  task :setup => :environment

  desc %{Clean up the pophealth instance (removes patients and queries) as well as our generated vendor/product/tests/executions in Cypress
    options
    pophealth_url   - the URL for the pophealth instance, up to and including the port number. Ex: http://localhost:3000
    pophealth_user  - the username (not email) for the popHealth user to conduct the cleanup as
    pophealth_password  - the password for the popHealth user
  }
  task :cleanup, [:pophealth_url, :pophealth_user, :pophealth_password] => :setup do |t, args|
    pophealth = Cypress::PophealthRoundtrip.new(args.to_hash)
    pophealth.cleanup
  end

  desc %{Generates a patient CAT I zip and uploads it to popHealth
      options
      cypress_user  - the username (full email) for the cypress user to be associated with the products/tests/vendors
      test_type     - the test type (Calculated/InpatientProductTest) to be uploaded
      measure_ids   - any additional arguments sent to this task will be passed to the roundtripper as an array of measure IDs (HQMF IDs)
  }
  task :generate_cat1_zip, [:cypress_user, :test_type] => :setup do |t, args|
    pophealth = Cypress::PophealthRoundtrip.new(args.to_hash)
    pophealth.generate_cat1_zip({:measure_ids => args.extras})
  end

  desc %{Import and calculate a zip in popHealth, and return the results to Cypress
    options
    pophealth_url   - the URL for the pophealth instance, up to and including the port number. Ex: http://localhost:3000
    pophealth_user  - the username (not email) for the popHealth user to conduct the roundtrip as
    pophealth_password  - the password for the popHealth user
    cypress_user  - the username (full email) for the cypress user to be associated with the products/tests/vendors
    cypress_password  - The password for the cypress user
    test_type     - the test type (Calculated/InpatientProductTest) to be uploaded
    measure_ids   - any additional arguments sent to this task will be passed to the roundtripper as an array of measure IDs (HQMF IDs)
  }
  task :zip_roundtrip, [:pophealth_url, :pophealth_user, :pophealth_password, :cypress_url, :cypress_user, :cypress_password, :test_type] => :setup do |t, args|
    pophealth = Cypress::PophealthRoundtrip.new(args.to_hash)
    pophealth.zip_roundtrip({:measure_ids => args.extras})
  end

  desc %{Import and calculate a particular category of measures, rather than specifiying measure IDs
    options
    pophealth_url   - the URL for the pophealth instance, up to and including the port number. Ex: http://localhost:3000
    pophealth_user  - the username (not email) for the popHealth user to conduct the roundtrip as
    pophealth_password  - the password for the popHealth user
    cypress_user  - the username (full email) for the cypress user to be associated with the products/tests/vendors
    cypress_password  - The password for the cypress user
    category        - The string representing the measure category to be included in the Cypress test. Capitalization matters. Example: Stroke
  }
  task :zip_roundtrip_category, [:pophealth_url, :pophealth_user, :pophealth_password, :cypress_url, :cypress_user, :cypress_password, :category] => [:setup, :cleanup] do |t, args|
    pophealth = Cypress::PophealthRoundtrip.new(args.to_hash)
    measures = Measure.where({category: args.category})
    measure_ids = measures.collect {|m| m.hqmf_id}
    measure_type = measures.first.type

    # need to convert the measure type into the correct test type
    test_type = case measure_type
      when 'ep'
        'CalculatedProductTest'
      when 'eh'
        'InpatientProductTest'
    end

    pophealth.zip_roundtrip({:measure_ids => measure_ids, :test_type => test_type})
  end

end
