class Product
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  belongs_to :vendor, index: true, touch: true
  has_many :product_tests, dependent: :destroy
  # NOTE: more relationships must be defined

  field :name, type: String
  field :version, type: String
  field :description, type: String

  validates :name, presence: true, uniqueness: { scope: :vendor, message: "Product name was already taken. Please choose another." }
  validates :ehr_type, presence: true
  validate :at_least_one_test_type?
  validates :vendor, presence: true

  field :ehr_type, type: String
  field :c1_test, type: Boolean
  field :c2_test, type: Boolean
  field :c3_test, type: Boolean
  field :c4_test, type: Boolean

  # state should be "passing", "failing", etc.
  field :state, type: String

  scope :passing, -> { where(state: "passing") }
  scope :failing, -> { where(state: "failing") }
  scope :incomplete, -> { where(state: "incomplete") }

  def at_least_one_test_type?
    errors.add(:tests, 'Product must include at least one certification test.') unless [ c1_test, c2_test, c3_test, c4_test ].any? { |is_true| is_true }
  end

end
