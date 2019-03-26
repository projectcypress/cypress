IndividualResult = QDM::IndividualResult

module QDM
  class IndividualResult
    store_in collection: 'individual_results'

    field :population_set_key, type: String
    field :correlation_id, type: String

    belongs_to :cqm_patient, class_name: 'CQM::Patient', inverse_of: :calculation_results

    def patient
      patient_id || cqm_patient
    end
  end
end
