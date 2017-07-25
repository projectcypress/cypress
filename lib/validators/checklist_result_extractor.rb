module Validators
  module ChecklistResultExtractor
    include Validators::AttributeExtractor

    # find all nodes that fulfill the data criteria
    def find_dc_node(template, valuesets, checked_criteria, source_criteria)
      passing = false
      # find nodes to search for the criteria
      reason_template, nodes = template_nodes(source_criteria, checked_criteria)
      # if the checked criteria has a code, the code and attributes will be checked
      # if the checked criteria does not have a code (e.g. Transfers), on the attiributes will be checked
      if checked_criteria.code || checked_criteria.negated_valueset
        # a codenode is a node, that includes the appropriate code
        codenodes = []
        # looks through every valueset associated with the source data criteria
        valuesets.each do |valueset|
          # once you find a matching node, you can stop
          next unless codenodes.empty?
          # If there is a negation, search for the code within the template
          codenodes = find_template_with_code(nodes, template, valueset, checked_criteria, reason_template)
          # When you get nodes that include a code, determine if it meets additinal criteria
          passing = passing_dc?(codenodes, source_criteria, checked_criteria)
        end
      elsif checked_criteria.attribute_code # CMS188v6
        valueset = source_criteria[:field_values].values[0].code_list_id
        codenodes = find_template_with_attribute([@file], template, valueset, checked_criteria.attribute_code)
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
      if source_criteria['value'] && source_criteria['value']['type'] != 'CD'
        node.xpath('./cda:value').blank? ? false : true
      elsif source_criteria['value'] && source_criteria['value']['type'] == 'CD'
        result_xpath = "./cda:value[@code='#{checked_criteria.attribute_code}'] or ./cda:entryRelationship[@typeCode='REFR']" \
                       "/cda:observation/cda:value[@code='#{checked_criteria.attribute_code}']"
        node.xpath(result_xpath).blank? ? false : true
      else
        find_attribute_values(node, checked_criteria.attribute_code, source_criteria)
      end
    end

    # returns true if source criteria has a reason (or negation)
    def source_criteria_has_reason(source_criteria)
      if source_criteria['negation']
        true
      elsif source_criteria['field_values'] && source_criteria['field_values'].keys[0] == 'REASON'
        true
      else
        false
      end
    end

    # find nodes to search for the criteria
    # sc = source_criteria, cc = checked_criteria
    def template_nodes(source_criteria, checked_criteria)
      sc = source_criteria
      cc = checked_criteria
      # if the source criteria does not have a reason, the whole document is returned to search
      # if the source criteria has a reason, return the list of nodes with the correction reason value set
      return false, [@file] unless source_criteria_has_reason(sc)
      # get valueset from the negation code list or field_values
      valueset = sc['negation'] ? sc['negation_code_list_id'] : sc.field_values['REASON'].code_list_id
      [true, @file.xpath("//cda:templateId[@root='2.16.840.1.113883.10.20.24.3.88']
        /..//*[@sdtc:valueSet='#{valueset}' and @code='#{cc.attribute_code}']")]
    end

    # searches all nodes to find ones with the correct template, valueset and code
    # cc is short for Checked_Criteria
    def find_template_with_code(nodes, template, valueset, cc, reason_template)
      return find_reason_code(nodes, template, valueset, cc) if reason_template
      # if it isn't a reason, the file node is the first
      codenodes = nodes.first.xpath("//cda:templateId[@root='#{template}']/..//*[@sdtc:valueSet='#{valueset}' and @code='#{cc.code}']")
      codenodes || []
    end

    # searches all nodes to find ones with the correct template, valueset and attribute code
    def find_template_with_attribute(nodes, template, valueset, attribute_code)
      codenodes = nodes.first.xpath("//cda:templateId[@root='#{template}']/..//*[@sdtc:valueSet='#{valueset}' and @code='#{attribute_code}']")
      codenodes || []
    end

    # cc is short for Checked_Criteria
    def find_reason_code(nodes, template, valueset, cc)
      # Return node once a matching node is found
      nodes.each do |node|
        # the negated device, order does not have a template id.
        if template == '2.16.840.1.113883.10.20.24.3.9'
          cn = node.parent.parent.parent.at_xpath("//*[@sdtc:valueSet='#{valueset}' and @code='#{cc.code}']")
        elsif cc.negated_valueset
          cn = node.parent.parent.parent.at_xpath("//cda:templateId[@root='#{template}']/..//*[@sdtc:valueSet='#{valueset}' and @nullFlavor='NA']")
        else
          cn = node.parent.parent.parent.at_xpath("//cda:templateId[@root='#{template}']/..//*[@sdtc:valueSet='#{valueset}' and @code='#{cc.code}']")
        end
        return [cn] unless cn.nil?
      end
      []
    end
  end
end
