class Bundle
  include Mongoid::Document
  
  field :title, type: String
  field :version, type: String
  field :license, type: String
  field :extensions, type: Array
  field :measures, type: Array
  field :records, type: Array
  
  validates_presence_of :name
  validates_presence_of :version

  def measure_defs
  	Measures.where(:bundle_id=>self.id)
  end

  def records
  	Record.where(:bundle_id=>self.id)
  end
  
end