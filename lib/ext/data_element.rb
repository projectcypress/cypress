module QDM
  # Represents QDM datatype (parent class of all generated QDM datatype models)
  class DataElement
    field :dataElementAttributes, type: Array, default: []
  end

  class DataElementAttribute
    include Mongoid::Document
    field :attribute_valueset, type: String
    field :attribute_name, type: String
  end
end
