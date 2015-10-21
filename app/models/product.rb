class Product
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  belongs_to :vendor, index: true, touch: true
  has_many :product_tests, :dependent => :destroy
  # NOTE: more relationships must be defined

  field :name, type: String
  field :version, type: String
  field :description, type: String
  field :ehr_type, type: String
  # state should be 'passing', 'failing', etc.
  field :state, type: String, default: 'incomplete'

  validates :name, presence: true,
                   uniqueness: { :scope => :vendor,
                                 :message => 'Product name was already taken. Please choose another.' }
  validates :ehr_type, presence: true, inclusion: { in: %w(provider hospital) }
  validates :vendor, presence: true
  validates :state, inclusion: { in: %w(passing failing incomplete) }

  scope :passing, -> { where(state: 'passing') }
  scope :failing, -> { where(state: 'failing') }
  scope :incomplete, -> { where(state: 'incomplete') }
end
