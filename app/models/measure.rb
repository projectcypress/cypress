class Measure
  include Mongoid::Document
  
  field :id, type: String
  field :sub_id, type: String
  field :name, type: String
  field :subtitle, type: String
  field :short_subtitle, type: String
  
  def key
    "#{self['id']}#{sub_id}"
  end
end