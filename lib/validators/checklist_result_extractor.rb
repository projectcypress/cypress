module Validators
  module ChecklistResultExtractor
    XPATH_CONSTS = {
      'ADMISSION_DATETIME' => './cda:effectiveTime/cda:low',
      'CUMULATIVE_MEDICATION_DURATION' => './../../../cda:doseQuantity',
      'DISCHARGE_DATETIME' => './cda:effectiveTime/cda:high',
      'FACILITY_LOCATION_ARRIVAL_DATETIME' => "./cda:participant[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.100']]/cda:time/cda:low",
      'FACILITY_LOCATION_DEPARTURE_DATETIME' => "./cda:participant[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.100']]/cda:time/cda:high",
      'FLFS' => "./sdtc:inFulfillmentOf1/sdtc:templateId[@root='2.16.840.1.113883.10.20.24.3.126']",
      'INCISION_DATETIME' => "./cda:entryRelationship/cda:procedure[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.89']]/cda:effectiveTime",
      'LENGTH_OF_STAY' => './cda:effectiveTime[./cda:low and ./cda:high]',
      'START_DATETIME' => "./cda:author[./cda:templateId[@root='2.16.840.1.113883.10.20.22.4.119']]/cda:time"
    }.freeze

    # find all nodes that fulfill the data criteria
    def find_dc_node(template, valuesets, checked_criteria, source_criteria)
      passing = false
      # find nodes to search for the criteria
      negated_template, nodes = template_nodes(source_criteria, checked_criteria)
      # if the checked criteria has a code, the code and attributes will be checked
      # if the checked criteria does not have a code (e.g. Transfers), on the attiributes will be checked
      if checked_criteria.code
        # a codenode is a node, that includes the appropriate code
        codenodes = []
        # looks through every valueset associated with the source data criteria
        valuesets.each do |valueset|
          # once you find a matching node, you can stop
          next unless codenodes.empty?
          # If there is a negation, search for the code within the template
          codenodes = find_template_with_code(nodes, template, valueset, checked_criteria.code, negated_template)
          # When you get nodes that include a code, determine if it meets additinal criteria
          passing = passing_dc?(codenodes, source_criteria, checked_criteria)
        end
      elsif checked_criteria.attribute_code # CMS188v6
        valueset = source_criteria[:field_values].values[0].code_list_id
        codenodes = find_template_with_code([@file], template, valueset, checked_criteria.attribute_code, negated_template)
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
      # if the critieria also has an attribute, check to see if the attribute criteria is also met with the node.
      if codenodes && check_attribute?(source_criteria, checked_criteria)
        codenodes.each do |codenode|
          next if passing
          # a node is passing if the attribute is also met
          passing = passing_node?(codenode.parent, source_criteria, checked_criteria)
        end
      end
      passing
    end

    def passing_node?(node, source_criteria, checked_criteria)
      # if the attribute is a result that isn't a code
      # if the attribute is a result that is a code
      # if the attribute is defined as a field value
      if source_criteria['value'] && source_criteria['value']['type'] != 'CD' # CMS146v5
        node.xpath('./cda:value').blank? ? false : true
      elsif source_criteria['value'] && source_criteria['value']['type'] == 'CD'
        node.xpath("./cda:value[@code='#{checked_criteria.attribute_code}']").blank? ? false : true
      else
        find_attribute_values(node, checked_criteria.attribute_code, source_criteria)
      end
    end

    # does a node need to be checked for an atttibute value
    def check_attribute?(source_criteria, checked_criteria)
      # don't check for an attribute if there isn't a attribute or result, or there is a negation
      # check for an attribute, if there is an attribute or result, and there isn't a negation
      if (checked_criteria.attribute_complete.nil? && checked_criteria.result_complete.nil?) || source_criteria['negation'] # CMS31v5
        false
      elsif (!checked_criteria.attribute_complete.nil? || !checked_criteria.result_complete.nil?) && !source_criteria['negation']
        true
      end
    end

    # find nodes to search for the criteria
    def template_nodes(source_criteria, checked_criteria)
      # if the source criteria does not have a negation, the whole document is returned to search
      # if the source criteria has a negation, return the list of nodes with the correction negation code list
      return false, [@file] unless source_criteria['negation'] == true
      [true, @file.xpath("//cda:templateId[@root='2.16.840.1.113883.10.20.24.3.88']
        /..//*[@sdtc:valueSet='#{source_criteria['negation_code_list_id']}' and @code='#{checked_criteria.attribute_code}']")]
    end

    # searches all nodes to find ones with the correct template, valueset and code
    def find_template_with_code(nodes, template, valueset, code, negated_template)
      return find_negated_code(nodes, template, valueset, code) if negated_template
      # if it isn't a negation, the file node is the first
      codenodes = nodes.first.xpath("//cda:templateId[@root='#{template}']/..//*[@sdtc:valueSet='#{valueset}' and @code='#{code}']")
      codenodes || []
    end

    def find_negated_code(nodes, template, valueset, code)
      # Return node once a matching node is found
      nodes.each do |node|
        # the negated device, order does not have a template id.
        if template == '2.16.840.1.113883.10.20.24.3.9'
          cn = node.parent.parent.parent.at_xpath("//*[@sdtc:valueSet='#{valueset}' and @code='#{code}']")
        else
          cn = node.parent.parent.parent.at_xpath("//cda:templateId[@root='#{template}']/..//*[@sdtc:valueSet='#{valueset}' and @code='#{code}']")
        end
        return [cn] unless cn.nil?
      end
      []
    end

    # searches a node for the existance of the attribute criteria, each field_value has a xpath relative to the template root
    def find_attribute_values(node, code, source_criteria)
      # xpath expressions with codes
      xpath_map = {
        'ANATOMICAL_LOCATION_SITE' => "./cda:targetSiteCode[@code='#{code}']",
        'DIAGNOSIS' => "./cda:entryRelationship/cda:act[./cda:code[@code='29308-4']]/cda:entryRelationship
                       /cda:observation/cda:value[@code='#{code}']", 'ORDINAL' => "./cda:priorityCode[@code='#{code}']",
        'DISCHARGE_STATUS' => "./sdtc:dischargeDispositionCode[@code='#{code}']", # CMS31v5
        'FACILITY_LOCATION' => "./cda:participant[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.100']]
                               /cda:participantRole/cda:code[@code='#{code}']",
        'LATERALITY' => "./cda:value/cda:qualifier[./cda:name/@code='182353008']/cda:value[@code='#{code}']",
        'ORDINALITY' => "./cda:entryRelationship/cda:observation[./code[@code='260870009']]/cda:value[@code='#{code}']",
        'PRINCIPAL_DIAGNOSIS' => "./cda:entryRelationship/cda:observation[./cda:code[@code='8319008']]/cda:value[@code='#{code}']", # CMS188v6
        'REASON' => "./cda:entryRelationship/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.88']]/cda:value[@code='#{code}']",
        'RESULT' => "./cda:value[@code='#{code}]", 'ROUTE' => "../../../cda:routeCode[@code='#{code}']",
        'SEVERITY' => "./cda:entryRelationship/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.22.4.8']]/cda:value[@code='#{code}']"
      }
      # XPATH_CONSTS are the expressions without codes
      xpath_map.merge!(XPATH_CONSTS)
      if source_criteria['field_values']
        results = node.xpath(xpath_map[source_criteria.field_values.keys[0]])
        return results.blank? ? false : true
      end
      false
    end
  end
end
