module Validators
  module AttributeExtractor
    XPATH_CONSTS = {
      'ADMISSION_DATETIME' => './cda:effectiveTime/cda:low',
      'CUMULATIVE_MEDICATION_DURATION' => './../../../cda:doseQuantity or ./../../../cda:repeatNumber',
      'DISCHARGE_DATETIME' => './cda:effectiveTime/cda:high or ./../../../cda:effectiveTime/cda:high',
      'FACILITY_LOCATION_ARRIVAL_DATETIME' => "./cda:participant[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.100']]/cda:time/cda:low",
      'FACILITY_LOCATION_DEPARTURE_DATETIME' => "./cda:participant[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.100']]/cda:time/cda:high",
      'FLFS' => "./sdtc:inFulfillmentOf1/sdtc:templateId[@root='2.16.840.1.113883.10.20.24.3.126']",
      'INCISION_DATETIME' => "./cda:entryRelationship/cda:procedure[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.89']]/cda:effectiveTime",
      'LENGTH_OF_STAY' => './cda:effectiveTime[./cda:low and ./cda:high]',
      'START_DATETIME' => "./cda:author[./cda:templateId[@root='2.16.840.1.113883.10.20.22.4.119']]/cda:time"
    }.freeze

    # does a node need to be checked for an atttibute value
    # sc = source_criteria, cc = checked_criteria
    def check_attribute?(source_criteria, checked_criteria)
      sc = source_criteria
      cc = checked_criteria
      # don't check for an attribute if there isn't a attribute or result, or there is a reason
      # check for an attribute, if there is an attribute or result, and there isn't a reason
      if (cc.attribute_complete.nil? && cc.result_complete.nil?) || source_criteria_has_reason(sc)
        false
      elsif (!cc.attribute_complete.nil? || !cc.result_complete.nil?) && !source_criteria_has_reason(sc)
        true
      end
    end

    # searches a node for the existance of the attribute criteria, each field_value has a xpath relative to the template root
    def find_attribute_values(node, code, source_criteria)
      # xpath expressions with codes
      xpath_map = {
        'DIAGNOSIS' => "./cda:entryRelationship/cda:act[./cda:code[@code='29308-4']]/cda:entryRelationship
                       /cda:observation/cda:value[@code='#{code}']", 'ORDINALITY' => "./cda:priorityCode[@code='#{code}']",
        'DISCHARGE_STATUS' => "./sdtc:dischargeDispositionCode[@code='#{code}']", # CMS31v5
        'FACILITY_LOCATION' => "./cda:participant[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.100']]
                               /cda:participantRole/cda:code[@code='#{code}']", 'ROUTE' => "../../../cda:routeCode[@code='#{code}']",
        'LATERALITY' => "./cda:value/cda:qualifier[./cda:name/@code='182353008']/cda:value[@code='#{code}']",
        'ORDINAL' => "./cda:entryRelationship/cda:observation[./cda:code[@code='260870009']]/cda:value[@code='#{code}']
                     or ./cda:priorityCode[@code='#{code}']", 'ANATOMICAL_LOCATION_SITE' => "./cda:targetSiteCode[@code='#{code}']",
        'PRINCIPAL_DIAGNOSIS' => "./cda:entryRelationship/cda:observation[./cda:code[@code='8319008']]/cda:value[@code='#{code}']", # CMS188v6
        'SEVERITY' => "./cda:entryRelationship/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.22.4.8']]/cda:value[@code='#{code}']"
      }
      # XPATH_CONSTS are the expressions without codes
      xpath_map.merge!(XPATH_CONSTS)
      if source_criteria['field_values']
        return node.xpath(xpath_map[source_criteria.field_values.keys[0]]).blank? ? false : true
      end
      false
    end
  end
end
