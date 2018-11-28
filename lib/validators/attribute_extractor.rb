module Validators
  module AttributeExtractor
    # XPATH_CONSTS contains a hash of attributes (e.g., relevantPeriod) and their relative path
    # relationship with the root of the QRDA template they are contained in.
    # The 'root' of the QRDA template corresponds to the location of the templateId that corresponds
    # with the QDM type being referenced (e.g., '2.16.840.1.113883.10.20.24.3.23' for Encounter Performed.)
    # This relative path needs to consistent across all QRDA templates, or should contain a leading '/''
    # (which will look at any depth) with an XPATH signature that is deterministic (e.g., authorDatetime).
    XPATH_CONSTS = {
      'relevantPeriod' => 'cda:effectiveTime/cda:low',
      'prevalencePeriod' => 'cda:effectiveTime/cda:low',
      'authorDatetime' => "/cda:author[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.155']]/cda:time",
      'relatedTo' => "sdtc:inFulfillmentOf1/sdtc:templateId[@root='2.16.840.1.113883.10.20.24.3.126']",
      'resultDatetime' => "cda:entryRelationship/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.22.4.2']]/cda:effectiveTime"
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
      # xpath_map contains a hash of attributes (e.g., relevantPeriod) and their relative path
      # relationship with the root of the QRDA template they are contained in.
      # xpath_map differs from the XPATH_CONSTS because the XPATH statements include a placeholder
      # for a 'code' that is passed in to perform the evaluation.
      xpath_map = {
        'components' => "cda:entryRelationship/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.149]/cda:code[@code='#{code}']",
        'diagnoses' => "cda:entryRelationship/cda:act[./cda:code[@code='29308-4']]/cda:entryRelationship
                       /cda:observation/cda:value[@code='#{code}']",
        'dischargeDisposition' => "sdtc:dischargeDispositionCode[@code='#{code}']", # CMS31v5
        'facilityLocations' => "cda:participant[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.100']]
                               /cda:participantRole/cda:code[@code='#{code}']",
        'admissionSource' => "cda:participant/cda:participantRole[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.151']]
                             /cda:code[@code='#{code}']", 'route' => "cda:routeCode[@code='#{code}']",
        'ordinality' => "cda:entryRelationship/cda:observation[./cda:code[@code='260870009']]/cda:value[@code='#{code}']
                     or cda:priorityCode[@code='#{code}']", 'anatomicalLocationSite' => "cda:targetSiteCode[@code='#{code}']",
        'principalDiagnosis' => "cda:entryRelationship/cda:observation[./cda:code[@code='8319008']]/cda:value[@code='#{code}']", # CMS188v6
        'severity' => "cda:entryRelationship/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.22.4.8']]/cda:value[@code='#{code}']"
      }
      # XPATH_CONSTS (the XPATH expressions without codes) are merged with the xpath_map (the XPATH expressions without codes)
      xpath_map.merge!(XPATH_CONSTS)
      if source_criteria['attributes']
        relative_path = relative_path_to_template_root(source_criteria['definition'])
        return node.xpath(relative_path + xpath_map[source_criteria.attributes[index].attribute_name]).blank? ? false : true
      end

      false
    end

    # TODO: relative_path_map currently only includes QDM types that cqm-parsers can import/export.
    # Other QDM types are not included.
    def relative_path_to_template_root(definition)
      relative_path_map = { 'adverse_event' => '../../',
                            'allergy_intolerance' => '../../../',
                            'assessment' => './',
                            'communication_from_patient_to_provider' => './',
                            'communication_from_provider_to_patient' => './',
                            'communication_from_provider_to_provider' => './',
                            'device' => '../../../',
                            'diagnosis' => './',
                            'diagnostic_study' => './',
                            'encounter' => './',
                            'immunization' => '../../../',
                            'intervention' => './',
                            'laboratory_test' => './',
                            'medication' => '../../../',
                            'physical_exam' => './',
                            'procedure' => './' }
      relative_path_map[definition]
    end
  end
end
