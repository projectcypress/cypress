class Measure
  include Mongoid::Document
  
  field :id, type: String
  field :sub_id, type: String
  field :name, type: String
  field :subtitle, type: String
  field :short_subtitle, type: String
  field :hqmf_id, type: String
  field :set_id, type: String
  field :nqf_id, type: String
  field :type, type: String
  field :category, type: String

  scope :top_level_by_type , ->(type){where({"type"=> type}).any_of({"sub_id" => nil}, {"sub_id" => "a"})}
  scope :top_level , any_of({"sub_id" => nil}, {"sub_id" => "a"})
  

  validates_presence_of :id
  validates_presence_of :name
  
  def key
    "#{self['id']}#{sub_id}"
  end
  
  def self.installed
    Measure.order_by([["id", :asc],["sub_id", :asc]]).to_a
  end
  

  # Finds all measures and groups the sub measures
  # @return Array - This returns an Array of Hashes. Each Hash will represent a top level measure with an ID, name, and category.
  #                 It will also have an array called subs containing hashes with an ID and name for each sub-measure.
  def self.all_by_measure
    reduce = 'function(obj,prev) {
                if (obj.sub_id != null)
                  prev.subs.push({id : obj.id + obj.sub_id, name : obj.subtitle});
              }'
    
    MONGO_DB.command( :group=> {:ns=>"measures", :key => {:id=>1, :name=>1, :category=>1}, :initial => {:subs => []}, "$reduce" => reduce})["retval"]
  end

  def display_name
    "#{self['nqf_id']} - #{name}"
  end
  
  def measure_id
    self['id']
  end
end