FactoryBot.define do
  factory :measure, class: Measure do
    entry = Rails.root.join('test', 'fixtures', 'artifacts', 'cms32v7.json')
    transient do
      seq_id { 1 }
    end
    source_measure = JSON.parse(File.read(entry), max_nesting: 100)
    description { "Measure Description #{seq_id}" }
    title { "Measure Name #{seq_id}" }

    cms_id { "CMS#{seq_id}v1" }
    hqmf_id { "53e3f13d-e5cf-445f-8dda-3720aff8401#{seq_id}" }
    hqmf_set_id { "7c00e09b-02dc-458b-8587-7f0347a443f#{seq_id}" }

    measure_scoring { 'CONTINUOUS_VARIABLE' }
    calculation_method { 'EPISODE_OF_CARE' }
    reporting_program_type { 'ep' }
    category { "none_#{seq_id / 2}" }

    source_data_criteria { source_measure['source_data_criteria'] }
    population_criteria { source_measure['population_criteria'] }

    main_cql_library { source_measure['main_cql_library'] }

    trait :diagnosis do
      after(:build) do |measure|
        diagnosis_sdc = QDM::Diagnosis.new(description: 'Diagnosis, Active => Pregnancy',
                                           codeListId: '1.5.6.7')
        measure.source_data_criteria << diagnosis_sdc
      end
    end
    trait :no_diagnosis do
    end

    factory  :measure_with_diagnosis, traits: [:diagnosis]
    factory  :measure_without_diagnosis, traits: [:no_diagnosis]

    factory  :static_measure do
      description { 'Static Measure Description' }
      title { 'Static Measure' }

      cms_id { source_measure['cms_id'] }
      hqmf_id { 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE' }
      hqmf_set_id { 'C621C7B6-EB1F-11E7-8C3F-9A214CF093AE' }

      measure_scoring { 'CONTINUOUS_VARIABLE' }
      calculation_method { 'EPISODE_OF_CARE' }
      reporting_program_type { 'ep' }
      category { 'none_0' }

      source_data_criteria { source_measure['source_data_criteria'] }
      population_criteria { source_measure['population_criteria'] }

      main_cql_library { source_measure['main_cql_library'] }

      after(:build) do |measure|
        source_measure['cql_libraries'].each do |cql_library|
          measure.cql_libraries << CQM::CQLLibrary.new(cql_library)
          cql_library['elm']['library']['valueSets'].each_pair do |_key, valuesets|
            valuesets.each do |valueset|
              measure.value_sets << ValueSet.where(oid: valueset['id']).first
            end
          end
          cql_library['elm']['library']['codes'].each_pair do |_key, codes|
            codes.each do |code|
              code_system_def = cql_library['elm']['library']['codeSystems']['def'].find { |code_sys| code_sys['name'] == code['codeSystem']['name'] }
              code_system_name = code_system_def['id']
              code_system_version = code_system_def['version']
              code_hash = 'drc-' + Digest::SHA2.hexdigest("#{code_system_name} #{code['id']} #{code['name']} #{code_system_version}")
              measure.value_sets << ValueSet.where(oid: code_hash).first
            end
          end
        end
        source_measure['population_sets'].each do |population_set|
          measure.population_sets << CQM::PopulationSet.new(population_set)
        end
        eh_clone = measure.clone
        eh_clone.id = BSON::ObjectId.new
        eh_clone.hqmf_id = 'AE65090C-EB1F-11E7-8C3F-9A214CF093AE'
        eh_clone.hqmf_set_id = 'E621C7B6-EB1F-11E7-8C3F-9A214CF093AE'
        eh_clone.reporting_program_type = 'eh'
        eh_clone.description = 'Static EH Measure Description'
        eh_clone.cms_id = 'CMS4321v1'
        eh_clone.save
      end
    end

    factory :static_proportion_measure do
      entry = Rails.root.join('test', 'fixtures', 'artifacts', 'CMS134v6.json')
      source_proportion_measure = JSON.parse(File.read(entry), max_nesting: 100)
      description { 'Static Proportion Measure Description' }
      title { 'Static Proportion Measure' }

      cms_id { source_proportion_measure['cms_id'] }
      hqmf_id { '40280382-5FA6-FE85-0160-0918E74D2075' }
      hqmf_set_id { '7B2A9277-43DA-4D99-9BEE-6AC271A07747' }

      measure_scoring { 'PROPORTION' }
      calculation_method { 'PATIENT' }
      reporting_program_type { 'ep' }
      category { 'none_0' }

      source_data_criteria { source_proportion_measure['source_data_criteria'] }
      population_criteria { source_measure['population_criteria'] }

      main_cql_library { source_proportion_measure['main_cql_library'] }

      after(:build) do |measure|
        source_proportion_measure['cql_libraries'].each do |cql_library|
          measure.cql_libraries << CQM::CQLLibrary.new(cql_library)
          cql_library['elm']['library']['valueSets'].each_pair do |_key, valuesets|
            valuesets.each do |valueset|
              measure.value_sets << ValueSet.where(oid: valueset['id']).first
            end
          end
          next unless cql_library['elm']['library']['codes']

          cql_library['elm']['library']['codes'].each_pair do |_key, codes|
            codes.each do |code|
              code_system_def = cql_library['elm']['library']['codeSystems']['def'].find { |code_sys| code_sys['name'] == code['codeSystem']['name'] }
              code_system_name = code_system_def['id']
              code_system_version = code_system_def['version']
              code_hash = 'drc-' + Digest::SHA2.hexdigest("#{code_system_name} #{code['id']} #{code['name']} #{code_system_version}")
              measure.value_sets << ValueSet.where(oid: code_hash).first
            end
          end
        end
        source_proportion_measure['population_sets'].each do |population_set|
          measure.population_sets << CQM::PopulationSet.new(population_set)
        end
      end
    end
  end
end
