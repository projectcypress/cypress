class ExecutionError
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :test_execution
  field :message, type: String
  field :msg_type, type: Symbol
  field :measure_id, type: String
  field :validation_type, type: String
  field :validator, type: String
  field :stratification, type: String
  field :location
  field :file_name, type: String
  validates :msg_type, presence: true
  validates :message, presence: true

  scope :by_type, ->(type) { where(msg_type: type) }
  scope :by_validation_type, ->(type) { where(validator_type: type) }
end
