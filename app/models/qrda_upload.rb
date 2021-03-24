class QrdaUpload
  include Mongoid::Document

  field :validator, type: String
  field :path, type: String
  embeds_many :execution_errors
end
