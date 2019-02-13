class CompiledResult
  include Mongoid::Document

  field :IPP, type: Boolean
  field :DENOM, type: Boolean
  field :NUMER, type: Boolean
  field :NUMEX, type: Boolean
  field :DENEX, type: Boolean
  field :DENEXCEP, type: Boolean
  field :MSRPOPL, type: Boolean
  field :OBSERV, type: Boolean
  field :MSRPOPLEX, type: Boolean

  field :correlation_id, type: String

  field :individual_results, type: Hash

  belongs_to :measure
  belongs_to :patient
end
