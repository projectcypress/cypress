# yes this is a bit ugly as it is aliasing The measure class but it
# works for now until we can truley unify these items accross applications
Measure = HealthDataStandards::CQM::Measure

class Measure
   field :bundle_id, type: BSON::ObjectId
   index :bundle_id => 1
   index id: 1, sub_id: 1

  def data_criteria
    self['hqmf_document']['data_criteria'].map {|key, val| {key => val}}
  end

end
