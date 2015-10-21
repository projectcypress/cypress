class Task

  include Mongoid::Document
  include Mongoid::Timestamps

  field :options, type: Hash
  field :expected_results, type: Hash 

  belongs_to :product_test
  has_many :test_executions


  def execute(params)
    throw NotImplementedError.new()
  end

  def records
    product_test.records
  end
  
end