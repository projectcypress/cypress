FactoryBot.define do
  factory :cqm_individual_result, class: CQM::IndividualResult do
    measure_id { Measure.find_by(hqmf_id: '40280382-5FA6-FE85-0160-0918E74D2075')._id }
  end

  factory :cv_cqm_individual_result, class: CQM::IndividualResult do
    measure_id { Measure.find_by(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE')._id }
  end
end
