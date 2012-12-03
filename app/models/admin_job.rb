class AdminValuesetJob

	include Mongoid::Document
	include Mongoid::Timestamps

	field :name, type: String
	field :log, type: Array
	field :status, type: String
	field :errors, type: Array
	field :total_length , type: Integer

	


end