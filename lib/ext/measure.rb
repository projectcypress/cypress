# yes this is a bit ugly as it is aliasing The measure class but it
# works for now until we can truley unify these items accross applications
Measure = HealthDataStandards::CQM::Measure

class Measure
  include HealthDataStandards::Export
  include HealthDataStandards::CQM
  field :bundle_id, type: BSON::ObjectId
  index bundle_id: 1
  index id: 1, sub_id: 1, cms_int: 1

  def display_name
    sub_id ? "#{cms_id} (#{sub_id}) #{name}" : "#{cms_id} #{name}"
  end

  def cms_int
    return 0 unless cms_id
    start_marker = 'CMS'
    end_marker = 'v'
    cms_id[/#{start_marker}(.*?)#{end_marker}/m, 1].to_i
  end

  def data_criteria
    self['hqmf_document']['data_criteria'].map { |key, val| { key => val } }
  end
end
