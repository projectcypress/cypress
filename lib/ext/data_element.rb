# frozen_string_literal: true

module QDM
  # Represents QDM datatype (parent class of all generated QDM datatype models)
  class DataElement
    field :dataElementAttributes, type: Array, default: []
    field :encounter_id, type: BSON::ObjectId
    field :denormalize_as_datetime, type: Boolean

    def occurs_after_date?(date)
      return [true, data_element_time] if data_element_time.to_i > date

      [false, nil]
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def data_element_time
      return relevantPeriod.low if respond_to?(:relevantPeriod) && relevantPeriod&.low
      return relevantDatetime if respond_to?(:relevantPeriod) && relevantDatetime
      return prevalencePeriod.low if respond_to?(:prevalencePeriod) && prevalencePeriod&.low
      return authorDatetime if respond_to?(:authorDatetime) && authorDatetime
      return resultDatetime if respond_to?(:resultDatetime) && resultDatetime
      return sentDatetime if respond_to?(:sentDatetime) && sentDatetime
      return participationPeriod.low if respond_to?(:participationPeriod) && participationPeriod&.low

      nil
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
  end

  class DataElementAttribute
    include Mongoid::Document
    field :attribute_valueset, type: String
    field :attribute_name, type: String
  end
end
