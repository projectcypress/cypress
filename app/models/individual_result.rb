# This should be moved into CQM Models

class IndividualResult
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :STRAT, :type => Integer
  field :IPP, :type => Integer
  field :DENOM, :type => Integer
  field :NUMER, :type => Integer
  field :NUMEX, :type => Integer
  field :DENEX, :type => Integer
  field :DENEXCEP, :type => Integer
  field :MSRPOPL, :type => Integer
  field :OBSERV, :type => Integer
  field :MSRPOPLEX, :type => Integer

  field :clause_results, :type => Hash
  field :episode_results, :type => Hash
  field :statement_results, :type => Hash

  field :extended_data, :type => Hash

  field :measure, type: BSON::ObjectId
  field :patient, type: BSON::ObjectId
  
end
