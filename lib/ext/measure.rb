# yes this is a bit ugly as it is aliasing The measure class but it
# works for now until we can truley unify these items accross applications
Measure = QDM::Measure

class Measure
  include Mongoid::Attributes::Dynamic
  store_in collection: 'measures'

  field :bundle_id, type: BSON::ObjectId
  
  field :name, type: String
  field :subtitle, type: String
  field :sub_id, type: String
  field :oids, type: Array
  field :hqmf_document, type: Hash

  scope :top_level , ->{any_of({"sub_id" => nil}, {"sub_id" => "a"})}

  index bundle_id: 1
  index id: 1, sub_id: 1, cms_int: 1

  def display_name
    sub_id ? "#{cms_id} (#{sub_id}) #{name}" : "#{cms_id} #{name}"
  end

  def name
    self['name'] ||= title
  end

  def cms_int
    return 0 unless cms_id
    start_marker = 'CMS'
    end_marker = 'v'
    cms_id[/#{start_marker}(.*?)#{end_marker}/m, 1].to_i
  end

  def key
    "#{self['hqmf_id']}#{sub_id}"
  end
end
