module Validators
  module ChecklistResultExtractor
    include Validators::AttributeExtractor

    # find all nodes that fulfill the data criteria
    def find_dc_node(template, checked_criteria, source_criteria)
      @checked_criteria = checked_criteria
      @source_criteria = source_criteria
      @template = template
      passing = false
      # find nodes to search for the criteria
      reason_template, nodes = template_nodes
      # if the checked criteria has a code, the code and attributes will be checked
      if @checked_criteria.code || @checked_criteria.negated_valueset
        neg_vs = @checked_criteria.negated_valueset ? @checked_criteria['selected_negated_valueset'] : nil
        codenodes = find_template_with_code(nodes, reason_template, neg_vs)
        # When you get nodes that include a code, determine if it meets additinal criteria
        passing = passing_dc?(codenodes)
      end
      if passing
        @checked_criteria.passed_qrda = true
        @checked_criteria.save
      end
    end

    def passing_dc?(codenodes)
      # return true if there is a matching node
      passing = true if !codenodes.empty? && !check_attribute?
      # if the critieria also has an attribute, check to see if the attribute criteria is also met with the node.
      if codenodes && check_attribute?
        codenodes.each do |codenode|
          next if passing
          # a node is passing if the attribute is also met
          passing = passing_node?(codenode.parent)
        end
      end
      passing
    end

    def passing_node?(node)
      # if the attribute is a result that isn't a code
      # if the attribute is a result that is a code
      # if the attribute is defined as a field value
      if @source_criteria.attributes[@checked_criteria.attribute_index]['attribute_name'] == 'result'
        if @source_criteria.attributes[@checked_criteria.attribute_index]['attribute_valueset']
          result_xpath = "./cda:value[@code='#{@checked_criteria.attribute_code}'] or ./cda:entryRelationship[@typeCode='REFR']" \
                         "/cda:observation/cda:value[@code='#{@checked_criteria.attribute_code}']"
          node.xpath(result_xpath).blank? ? false : true
        else
          node.xpath('./cda:value').blank? ? false : true
        end
      else
        find_attribute_values(node, @checked_criteria.attribute_code, @checked_criteria.attribute_index)
      end
    end

    # returns true if source criteria has a reason (or negation)
    def source_criteria_has_reason(index)
      if @source_criteria['attributes'] && (%w[reason negationRationale].include? @source_criteria['attributes'][index].attribute_name)
        true
      else
        false
      end
    end

    # find nodes to search for the criteria
    def template_nodes
      # if the source criteria does not have a reason, the whole document is returned to search
      # if the source criteria has a reason, return the list of nodes with the correction reason value set
      return false, [@file] unless source_criteria_has_reason(@checked_criteria.attribute_index)
      # get valueset from the negation code list or field_values
      [true, @file.xpath("//cda:templateId[@root='2.16.840.1.113883.10.20.24.3.88']
        /..//*[@code='#{@checked_criteria.attribute_code}']")]
    end

    # searches all nodes to find ones with the correct template, valueset and code
    def find_template_with_code(nodes, reason_template, negation_valueset = nil)
      return find_reason_code(nodes, negation_valueset) if reason_template
      # if it isn't a reason, the file node is the first
      codenodes = nodes.first.xpath("//cda:templateId[@root='#{@template}']/..//*[@code='#{@checked_criteria.code}']")
      codenodes || []
    end

    # searches all nodes to find ones with the correct template, valueset and attribute code
    def find_template_with_attribute(nodes, attribute_code)
      codenodes = nodes.first.xpath("//cda:templateId[@root='#{@template}']/..//*[@code='#{attribute_code}']")
      codenodes || []
    end

    def find_reason_code(nodes, valueset)
      # Return node once a matching node is found
      nodes.each do |node|
        rel_path = relative_path_to_template_root(@source_criteria['definition'])
        cn = if @checked_criteria.negated_valueset
               node.at_xpath(rel_path + "/cda:templateId[@root='#{@template}']/..//*[@sdtc:valueSet='#{valueset}' and @nullFlavor='NA']")
             else
               node.at_xpath(rel_path + "/cda:templateId[@root='#{@template}']/..//*[@code='#{@checked_criteria.code}']")
             end
        return [cn] unless cn.nil?
      end
      []
    end
  end
end
