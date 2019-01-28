FactoryBot.define do
  factory :individual_result, class: CQM::IndividualResult do
    IPP { 1 }
    DENOM { 1 }
    NUMER { 0 }
    DENEXCEP { 0 }
    DENEX { 0 }
    factory :individual_bundle_result do
      transient do
        bundleId { Bundle.find_by(name: 'Static Bundle')._id }
      end
      measure_id { Measure.find_by(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE', bundle_id: bundleId)._id }
      before :create do |result, options|
        result.extendedData = { correlation_id: options.bundleId }
      end
    end
  end
end
