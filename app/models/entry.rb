class Entry
  include Mongoid::Document
  embedded_in :entry_list, polymorphic: true
  
  field :time, type: Integer
  field :start_time, type: Integer
  field :end_time, type: Integer
  field :status, type: Symbol
  field :codes, type: Hash
  field :value, type: Hash
end