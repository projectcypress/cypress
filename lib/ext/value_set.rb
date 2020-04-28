ValueSet = CQM::ValueSet
Concept = CQM::Concept

class ValueSet
  include Mongoid::Document
  store_in collection: 'health_data_standards_svs_value_sets'

  belongs_to :bundle, class_name: 'Bundle', inverse_of: :value_sets

  def snomed_codes?
    concepts.any? { |concept| concept.code_system_oid == '2.16.840.1.113883.6.96' }
  end
end

class Concept
  # TODO: Remove the blacklist and whitelist fields when the Bonnie-created bundles
  # stop including them.
  field :black_list, type: Boolean
  field :white_list, type: Boolean
end
