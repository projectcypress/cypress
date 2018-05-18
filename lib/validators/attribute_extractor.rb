module Validators
  module AttributeExtractor
    XPATH_CONSTS = {
      'relevantPeriod' => './cda:effectiveTime/cda:low',
      'prevalencePeriod' => './cda:effectiveTime/cda:low',
      'authorDatetime' => "../../..//cda:author[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.155']]/cda:time",
      'relatedTo' => "./sdtc:inFulfillmentOf1/sdtc:templateId[@root='2.16.840.1.113883.10.20.24.3.126']",
      'resultDatetime' => "./cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.22.4.2']]/cda:effectiveTime"
    }.freeze

    # does a node need to be checked for an atttibute value
    # sc = source_criteria, cc = checked_criteria
    def check_attribute?(source_criteria, checked_criteria)
      sc = source_criteria
      cc = checked_criteria
      # don't check for an attribute if there isn't a attribute or result, or there is a reason
      # check for an attribute, if there is an attribute or result, and there isn't a reason
      if (cc.attribute_complete.nil? && cc.result_complete.nil?) || source_criteria_has_reason(sc, checked_criteria.attribute_index)
        false
      elsif (!cc.attribute_complete.nil? || !cc.result_complete.nil?) && !source_criteria_has_reason(sc, checked_criteria.attribute_index)
        true
      end
    end

    # searches a node for the existance of the attribute criteria, each field_value has a xpath relative to the template root
    def find_attribute_values(node, code, source_criteria, index)
      # xpath expressions with codes
      xpath_map = {
        'components' => "./cda:entryRelationship/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.149]/cda:code[@code='#{code}']",
        'diagnoses' => "./cda:entryRelationship/cda:act[./cda:code[@code='29308-4']]/cda:entryRelationship
                       /cda:observation/cda:value[@code='#{code}']",
        'dischargeDisposition' => "./sdtc:dischargeDispositionCode[@code='#{code}']", # CMS31v5
        'facilityLocations' => "./cda:participant[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.100']]
                               /cda:participantRole/cda:code[@code='#{code}']",
        'admissionSource' => "./cda:participant/cda:participantRole[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.151']]
                             /cda:code[@code='#{code}']",
        'route' => "../../../cda:routeCode[@code='#{code}']",
        'ordinality' => "./cda:entryRelationship/cda:observation[./cda:code[@code='260870009']]/cda:value[@code='#{code}']
                     or ./cda:priorityCode[@code='#{code}']", 'anatomicalLocationSite' => "./cda:targetSiteCode[@code='#{code}']",
        'principalDiagnosis' => "./cda:entryRelationship/cda:observation[./cda:code[@code='8319008']]/cda:value[@code='#{code}']", # CMS188v6
        'severity' => "./cda:entryRelationship/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.22.4.8']]/cda:value[@code='#{code}']"
      }
      # XPATH_CONSTS are the expressions without codes
      xpath_map.merge!(XPATH_CONSTS)
      if source_criteria['attributes']
        return node.xpath(xpath_map[source_criteria.attributes[index].attribute_name]).blank? ? false : true
      end
      false
    end
  end
end
