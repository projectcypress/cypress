class Bundle
  include Mongoid::Document
  
  field :name, type: String
  field :version, type: String
  field :license, type: String
  field :extensions, type: Array
  field :measures, type: Array
  
  validates_presence_of :name
  validates_presence_of :version
end