class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  field :options, type: Hash
  field :expected_results, type: Hash

  belongs_to :product_test
  has_many :test_executions
end
