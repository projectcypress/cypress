# TODO: Work with Bonnie team to establish Measure model in cqm-models
class Measure
  include Mongoid::Document
  include Mongoid::Timestamps

  MSRPOPL = 'MSRPOPL'.freeze

  store_in collection: 'measures'
  # Cypress stores the bundle id for the measure
  field :bundle_id, type: BSON::ObjectId
  # Cypress stores the original id for the measure in bonnie
  field :bonnie_measure_id, type: String

  field :id, :as => :id, :type => String
  field :sub_id, :type => String
  field :cms_id, :type => String
  field :name, :type => String
  field :description, :type => String
  field :subtitle, :type => String
  field :short_subtitle, :type => String
  field :hqmf_id, :type => String
  field :hqmf_set_id, :type => String
  field :hqmf_version_number, :type => String
  field :nqf_id, :type => String
  field :type, :type => String
  field :category, :type => String
  field :population_ids, :type => Hash
  field :oids, :type => Array

  field :population_criteria, :type => Hash
  field :data_criteria, :type => Hash, :default => {}
  field :source_data_criteria, :type => Hash, :default => {}
  field :measure_period, :type => Hash
  field :populations, :type => Array
  field :hqmf_document, :type => Hash
  field :continuous_variable, :type => Boolean
  field :episode_of_care, :type => Boolean
  field :value_sets, :type => Array

  # CQL specific additions
  # field :attributes, :type => Array
  field :elm_annotations, :type => Hash
  field :observations, :type => Array
  field :cql, :type => Array
  field :elm, :type => Array
  field :main_cql_library, :type => String
  field :cql_statement_dependencies, :type => Hash
  field :populations_cql_map, :type => Hash
  field :value_set_oid_version_objects, :type => Array, :default => []

  scope :top_level, -> { where(:sub_id.in => [nil, 'a']) }

  index :bundle_id => 1
  index :id => 1, :sub_id => 1, :cms_int => 1

  validates :id, :presence => true
  validates :name, :presence => true

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
