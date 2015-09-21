class Product

	include Mongoid::Document
	include Mongoid::Timestamps

	belongs_to :vendor, index: true, touch: true
	# NOTE: more relationships must be defined

	field :name, type: String
	field :version, type: String
	field :description, type: String

	validates_presence_of :name

	# methods must be added

end