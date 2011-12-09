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
  
  def self.installed
    Measure.order_by([["id", :asc],["sub_id", :asc]]).to_a
  end
  
  def self.top_level
    Measure.installed.select do |measure|
      !measure.sub_id || measure.sub_id=='a'
    end
  end

  def display_name
    "#{self['id']} - #{name}"
  end
  
  def measure_id
    self['id']
  end
  
    

end