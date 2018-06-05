FactoryBot.define do
  factory :measure, class: Measure do
    entry = Rails.root.join('test', 'fixtures', 'artifacts', 'cms127v7.json')
    source_measure = JSON.parse(File.read(entry), max_nesting: 100)
    sequence(:name) { |i| "Measure Name #{i}" }
    sequence(:hqmf_id) { |i| "53e3f13d-e5cf-445f-8dda-3720aff8401#{i}" }
    sequence(:hqmf_set_id) { |i| "7c00e09b-02dc-458b-8587-7f0347a443f#{i}" }
    continuous_variable false
    category 'none'
    type 'ep'
    episode_of_care true
    trait :diagnosis do
      hqmf_doc = { 'source_data_criteria' => { 'DiagnosisActivePregnancy' =>
                                               { 'title'  => 'Pregnancy',
                                                 'description' => 'Diagnosis, Active => Pregnancy',
                                                 'standard_category' => 'diagnosis_condition_problem',
                                                 'qds_data_type' => 'diagnosis_active',
                                                 'code_list_id' => '1.5.6.7',
                                                 'type' => 'conditions',
                                                 'definition' => 'diagnosis',
                                                 'hard_status' => false,
                                                 'negation' => false,
                                                 'source_data_criteria' => 'DiagnosisActivePregnancy' } },
                   'data_criteria'  => { 'DiagnosisActivePregnancy' =>
                                        { 'title'  => 'Pregnancy',
                                          'description' => 'Diagnosis, Active => Pregnancy',
                                          'standard_category' => 'diagnosis_condition_problem',
                                          'qds_data_type' => 'diagnosis_active',
                                          'code_list_id' => '1.5.6.7',
                                          'type' => 'conditions',
                                          'definition' => 'diagnosis',
                                          'hard_status' => false,
                                          'negation' => false,
                                          'field_values' => {
                                            'ORDINAL' => {
                                              'type' => 'CD',
                                              'code_list_id' => '1.16.17.18',
                                              'title' => 'Principal'
                                            }
                                          },
                                          'source_data_criteria' => 'DiagnosisActivePregnancy' } } }
      hqmf_document { hqmf_doc }
    end
    trait :no_diagnosis do
      hqmf_doc = { 'source_data_criteria' => { 'PhysicalExamFindingBmiPercentile' =>
                                               { 'title'  => 'BMI percentile',
                                                 'description' => 'Physical Exam, Finding => BMI percentile',
                                                 'standard_category' => 'physical_exam',
                                                 'qds_data_type' => 'physical_exam',
                                                 'code_list_id' => '1.7.8.9',
                                                 'type' => 'physical_exams',
                                                 'definition' => 'physical_exam',
                                                 'hard_status' => false,
                                                 'negation' => false,
                                                 'source_data_criteria' => 'PhysicalExamFindingBmiPercentile' } },
                   'data_criteria'  => { 'PhysicalExamFindingBmiPercentile_precondition_8' =>
                                        { 'title'  => 'BMI percentile',
                                          'description' => 'Physical Exam, Finding => BMI percentile',
                                          'standard_category' => 'physical_exam',
                                          'qds_data_type' => 'physical_exam',
                                          'code_list_id' => '1.7.8.9',
                                          'type' => 'physical_exams',
                                          'definition' => 'physical_exam',
                                          'hard_status' => false,
                                          'negation' => false,
                                          'source_data_criteria' => 'PhysicalExamFindingBmiPercentile',
                                          'temporal_references' => [
                                            { 'type' => 'DURING',
                                              'reference' => 'MeasurePeriod' }
                                          ] } } }
      hqmf_document { hqmf_doc }
    end

    factory  :measure_with_diagnosis, traits: [:diagnosis]
    factory  :measure_without_diagnosis, traits: [:no_diagnosis]

    factory  :static_measure do
      name 'Static Measure'
      cms_id source_measure['cms_id']
      hqmf_id 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'
      hqmf_set_id 'C621C7B6-EB1F-11E7-8C3F-9A214CF093AE'

      continuous_variable source_measure['continuous_variable']
      category 'static'
      type 'ep'
      sub_id 'a'

      episode_of_care source_measure['episode_of_care']
      hqmf_document { source_measure['hqmf_document'] }
      source_data_criteria { source_measure['source_data_criteria'] }
      population_criteria { source_measure['population_criteria'] }
      populations source_measure['populations']
      measure_period { source_measure['measure_period'] }
      oids source_measure['oids']
      population_ids { source_measure['population_ids'] }
    end
  end
end
