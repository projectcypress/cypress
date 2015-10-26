class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  field :options, type: Hash
  field :expected_results, type: Hash
  field :state, type: Symbol

  belongs_to :product_test
  has_many :test_executions
end
