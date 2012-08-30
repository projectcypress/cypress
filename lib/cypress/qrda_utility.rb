module Cypress
  class QrdaUtility
  

    # Extract and return measure results from a PQRI document and add to the reported results
    # for this test.
    def self.extract_results(doc, id_map)
      # the measure IDs in the report must be a subset of what the product is
      # allowed to test (in the measure_map)
      # reverse the hash of nqf#=>product-specific-measure-id
      measure_map = id_map.invert if id_map
      doc = (doc.kind_of? String )? Nokogiri::XML::Document.new(doc) : doc
      
      #the nodes we want will have a child "templateId" with root = 2.16.840.1.113883.10.20.27.3.1
      result_nodes = doc.xpath('/xmlns:ClinicalDocument/xmlns:component/xmlns:structuredBody/xmlns:component/xmlns:section/xmlns:entry/xmlns:organizer/xmlns:templateId[@root = "2.16.840.1.113883.10.20.27.3.1"]/parent::*')
      results ||= {}
      result_nodes.each do |result_node|
        key = result_node.at_xpath('xmlns:reference/xmlns:externalDocument/xmlns:id[@root = "2.16.840.1.113883.3.560.1"]')['extension']
        key = measure_map[key] if id_map

        numerator   = get_measure_attr(result_node,'NUMER')
        denominator = get_measure_attr(result_node,'DENOM')
        initial_population = get_measure_attr(result_node,'IPP')
        measure_population = get_measure_attr(result_node,'MSRPOPL')
        numerator_exclusions   = get_measure_attr(result_node,'NUMEX')
        denominator_exclusions = get_measure_attr(result_node,'DENEX')
        denominator_exceptions = get_measure_attr(result_node,'EXCEP')

        results[key] = {'measure_population' => measure_population, 'initial_population' => initial_population, \
                        'numerator'   => numerator  , 'numerator_exclusions'   => numerator_exclusions, \
                        'denominator' => denominator, 'denominator_exclusions' => denominator_exclusions, 'denominator_exceptions' => denominator_exceptions \
                       } if key
      end
      
      return results
    end

    private
    def self.get_measure_attr(node, name)
      xpath = 'xmlns:component/xmlns:observation/xmlns:value[@code = "'+ name +'"]/following::xmlns:entryRelationship/xmlns:observation/xmlns:value'
      result = node.at_xpath(xpath)
      if !result.nil?
        return result['value'].to_i
      else
        return '-'
      end
    end

  end
end