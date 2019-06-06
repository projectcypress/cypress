IndividualResult = CQM::IndividualResult

module CQM
  class IndividualResult
    store_in collection: 'individual_results'

    field :population_set_key, type: String
    field :correlation_id, type: String
    field :file_name, type: String
  end
end
