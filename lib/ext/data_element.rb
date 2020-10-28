module QDM
  # Represents QDM datatype (parent class of all generated QDM datatype models)
  class DataElement
    field :dataElementAttributes, type: Array, default: []
    field :encounter_id, type: BSON::ObjectId
    field :qualifier_name, type: String
    field :qualifier_value, type: String

    def occurs_during_range(low_time, high_time)
      det = data_element_time
      return false unless det
      return det >= low_time && det <= high_time if low_time && high_time
      return det >= low_time if low_time
      return det <= high_time if high_time

      false
    end

    def data_element_time
      return relevantPeriod.low if respond_to?('relevantPeriod') && relevantPeriod&.low
      return relevantDatetime if respond_to?('relevantDatetime') && relevantDatetime
      return prevalencePeriod.low if respond_to?('prevalencePeriod') && prevalencePeriod&.low
      return participationPeriod.low if respond_to?('participationPeriod') && participationPeriod&.low
      return authorDatetime if respond_to?('authorDatetime') && authorDatetime
      return resultDatetime if respond_to?('resultDatetime') && resultDatetime
      return activeDatetime if respond_to?('activeDatetime') && activeDatetime
      return incisionDatetime if respond_to?('incisionDatetime') && incisionDatetime
      return receivedDatetime if respond_to?('receivedDatetime') && receivedDatetime
      return sentDatetime if respond_to?('sentDatetime') && sentDatetime
      return birthDatetime if respond_to?('birthDatetime') && birthDatetime
      return expiredDatetime if respond_to?('expiredDatetime') && expiredDatetime
    end
  end

  class DataElementAttribute
    include Mongoid::Document
    field :attribute_valueset, type: String
    field :attribute_name, type: String
  end
end
