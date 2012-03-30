module Cypress
  class PqriUtility
  
    # Extract and return measure results from a PQRI document and add to the reported results
    # for this test.
    def self.extract_results(doc)
      doc = (doc.kind_of? String )? Nokogiri::XML::Document.new(doc) : doc
      results ||= {}
      result_nodes = doc.xpath('/submission/measure-group/provider/pqri-measure')

      result_nodes.each do |result_node|
        key = result_node.at_xpath('pqri-measure-number').text
        numerator = result_node.at_xpath('meets-performance-instances').text.to_i
        exclusions = result_node.at_xpath('performance-exclusion-instances').text.to_i
        antinumerator = result_node.at_xpath('performance-not-met-instances').text.to_i
        denominator = numerator + antinumerator

        results[key] = {'denominator' => denominator, 'numerator' => numerator, 'exclusions' => exclusions, 'antinumerator' => antinumerator}
      end

      return results
    end

    # Validate the pqri submission against the xsd.
    #
    # Return value is an array of all errors found.
    def self.validate(doc)
      puts doc
      doc = (doc.kind_of? String) ? Nokogiri::XML::Document.new(doc) : doc
      validation_errors = []
      schema = Nokogiri::XML::Schema(open(Rails.root.join("public","Registry_Payment.xsd")))

      schema.validate(doc).each do |error|
        validation_errors << error.message
      end

      return validation_errors
    end
  end
end