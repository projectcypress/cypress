IndividualResult = QDM::IndividualResult

module QDM
  class IndividualResult
    store_in collection: 'individual_results'

    field :population_set_key, type: String
    field :correlation_id, type: String
    field :file_name, type: String

    belongs_to :cqm_patient, class_name: 'CQM::Patient', inverse_of: :calculation_results

    # The patient in the cqm-model QDM::IndividualResult is the QDM:Patient
    # This method overrides the QDM:Patient with the CQM:Paient
    def patient
      patient_id || cqm_patient
    end
  end
end
