class Measure
  include Mongoid::Document
  
  field :id, type: String
  field :sub_id, type: String
  field :name, type: String
  field :subtitle, type: String
  field :short_subtitle, type: String
  
  validates_presence_of :id
  validates_presence_of :name
  
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
  
  # Finds all measures and groups the sub measures
  # @return Array - This returns an Array of Hashes. Each Hash will represent a top level measure with an ID, name, and category.
  #                 It will also have an array called subs containing hashes with an ID and name for each sub-measure.
  def self.all_by_measure
    reduce = 'function(obj,prev) {
                if (obj.sub_id != null)
                  prev.subs.push({id : obj.id + obj.sub_id, name : obj.subtitle});
              }'
    
    MONGO_DB['measures'].group(:key => [:id, :name, :category], :initial => {:subs => []}, :reduce => reduce)
  end
  
  def self.measure_categories(type = :all_by_measure)
    case type
      when :top_level
        measures = Measure.top_level
        measures.group_by { |t| t['category'] }
      when :all_by_measure
        measures = Measure.all_by_measure
        measures.group_by { |t| t['category'] }
    end
  end

  def display_name
    "#{self['id']} - #{name}"
  end
  
  def measure_id
    self['id']
  end
end