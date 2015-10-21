class ProductTest
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :product, index: true, touch: true
  belongs_to :bundle, index: true

  has_many :test_executions, :dependent => :destroy

  # this the hqmf id of the measure
  field :measure_id, type: String
  # Test Details
  field :name, type: String
  field :description, type: String

  field :expected_results, type: Hash
  field :status_message, type: String
  field :state, type: Symbol

  validates :name, presence: true
  validates :product, presence: true
  validates :measure_id, presence: true

  def execute(_params)
    fail NotImplementedError
  end

  def records
    fail NotImplementedError
  end
end
