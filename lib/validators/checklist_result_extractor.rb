module Validators
  module ChecklistResultExtractor
    XPATH_CONSTS = {
      'ADMISSION_DATETIME' => './cda:effectiveTime/cda:low',
      'CUMULATIVE_MEDICATION_DURATION' => './../../../cda:doseQuantity',
      'DISCHARGE_DATETIME' => './cda:effectiveTime/cda:high',
      'FACILITY_LOCATION_ARRIVAL_DATETIME' => "./cda:participant[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.100']]/cda:time/cda:low",
      'FACILITY_LOCATION_DEPARTURE_DATETIME' => "./cda:participant[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.100']]/cda:time/cda:high",
      'FLFS' => "./sdtc:inFulfillmentOf1/sdtc:templateId[@root='2.16.840.1.113883.10.20.24.3.126']",
      'INCISION_DATETIME' => "./cda:entryRelationship/cda:templateId[@root='2.16.840.1.113883.10.20.24.3.89']/cda:effectiveTime",
      'LENGTH_OF_STAY' => './cda:effectiveTime[./cda:low and ./cda:high]',
      'START_DATETIME' => './cda:effectiveTime/cda:low'
    }.freeze

    def find_dc_node(template, valuesets, checked_criteria, source_criteria)
      passing = false
      nodes = template_nodes(source_criteria, checked_criteria)
      if checked_criteria.code
        codenodes = []
        valuesets.each do |valueset|
          next unless codenodes.empty?
          # If there is a negation, search for the code within the template
          codenodes = find_template_with_code(nodes, template, valueset, checked_criteria.code)
          passing = passing_dc?(codenodes, source_criteria, checked_criteria)
        end
      elsif checked_criteria.attribute_code # CMS188v6
        valueset = source_criteria[:field_values].values[0].code_list_id
        codenodes = find_template_with_code([@file], template, valueset, checked_criteria.attribute_code)
        passing = true unless codenodes.empty?
      end
      if passing
        checked_criteria.passed_qrda = true
        checked_criteria.save
      end
    end

    def passing_dc?(codenodes, source_criteria, checked_criteria)
      # return true if there is a matching node
      passing = true if !codenodes.empty? && !check_attribute?(source_criteria, checked_criteria)
      if codenodes && check_attribute?(source_criteria, checked_criteria)
        codenodes.each do |codenode|
          next if passing
          passing = passing_node?(codenode.parent, source_criteria, checked_criteria)
        end
      end
      passing
    end

    def passing_node?(node, source_criteria, checked_criteria)
      if source_criteria['value'] && source_criteria['value']['type'] != 'CD' # CMS146v5
        node.xpath('./cda:value').blank? ? false : true
      elsif source_criteria['value'] && source_criteria['value']['type'] == 'CD'
        node.xpath("./cda:value[@code='#{checked_criteria.attribute_code}']").blank? ? false : true
      else
        find_attribute_values(node, checked_criteria.attribute_code, source_criteria)
      end
    end

    def check_attribute?(source_criteria, checked_criteria)
      if (checked_criteria.attribute_complete.nil? && checked_criteria.result_complete.nil?) || source_criteria['negation'] # CMS31v5
        false
      elsif (!checked_criteria.attribute_complete.nil? || !checked_criteria.result_complete.nil?) && !source_criteria['negation']
        true
      end
    end

    def template_nodes(source_criteria, checked_criteria)
      if source_criteria['negation'] == true
        @file.xpath("//cda:templateId[@root='2.16.840.1.113883.10.20.24.3.88']/..//*[@sdtc:valueSet='#{source_criteria['negation_code_list_id']}'
          and @code='#{checked_criteria.attribute_code}']")
      else
        [@file]
      end
    end

    def find_template_with_code(nodes, template, valueset, code)
      codenodes = nil
      nodes.each do |node|
        codenodes = if nodes.size > 1
                      node.at_xpath("//cda:templateId[@root='#{template}']/..//*[@sdtc:valueSet='#{valueset}' and @code='#{code}']") unless codenodes
                    else
                      node.xpath("//cda:templateId[@root='#{template}']/..//*[@sdtc:valueSet='#{valueset}' and @code='#{code}']")
                    end
      end
      codenodes || []
    end

    def find_attribute_values(node, code, source_criteria)
      xpath_map = {
        'ANATOMICAL_LOCATION_SITE' => "./cda:targetSiteCode[@code='#{code}']", 'LATERALITY' => "./cda:targetSiteCode[@code='#{code}']",
        'DIAGNOSIS' => "./cda:entryRelationship/cda:act[./cda:code[@code='29308-4']]/cda:entryRelationship
                       /cda:observation/cda:value[@code='#{code}']",
        'DISCHARGE_STATUS' => "./sdtc:dischargeDispositionCode[@code='#{code}']", # CMS31v5
        'FACILITY_LOCATION' => "./cda:participant[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.100']]
                               /cda:participantRole/cda:code[@code='#{code}']",
        'ORDINAL' => "./cda:priorityCode[@code='#{code}']", # CMS178v6
        'ORDINALITY' => "./cda:entryRelationship/cda:observation[./code[@code='260870009']]/cda:value[@code='#{code}']",
        'PRINCIPAL_DIAGNOSIS' => "./cda:entryRelationship/cda:observation[./cda:code[@code='8319008']]/cda:value[@code='#{code}']", # CMS188v6
        'REASON' => "./cda:entryRelationship/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.88']]/cda:value[@code='#{code}']",
        'RESULT' => "./cda:value[@code='#{code}]", 'ROUTE' => "//cda:routeCode[@code='#{code}]",
        'SEVERITY' => "./cda:entryRelationship/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.22.4.8']]/cda:value[@code='#{code}']"
      }
      xpath_map.merge!(XPATH_CONSTS)
      if source_criteria['field_values']
        results = node.xpath(xpath_map[source_criteria.field_values.keys[0]])
        return results.blank? ? false : true
      end
      false
    end
  end
end
