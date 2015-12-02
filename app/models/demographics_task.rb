class DemographicsTask < C4Task
  field :primary_filter, type: String
  field :secondary_filter, type: String

  def filters
    %w(race ethnicity gender payer)
  end



end
