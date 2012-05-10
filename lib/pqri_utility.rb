module Cypress
  class PqriUtility
  
    SCHEMA_VERSIONS = {
      "2.0" => "Registry_Payment.xsd",
      "3.0" => "PQRI_2010.xsd"
    }
    # Extract and return measure results from a PQRI document and add to the reported results
    # for this test.
    def self.extract_results(doc, id_map)
      doc = (doc.kind_of? String )? Nokogiri::XML::Document.new(doc) : doc
      results ||= {}
      result_nodes = doc.xpath('/submission/measure-group/provider/pqri-measure')

      # the measure IDs in the report must be a subset of what the product is
      # allowed to test (in the measure_map)
      # reverse the hash of nqf#=>product-specific-measure-id
      measure_map = id_map.invert if id_map
   
      result_nodes.each do |result_node|
        key = result_node.at_xpath('pqri-measure-number').text
        key = measure_map[key] if id_map
        numerator = result_node.at_xpath('meets-performance-instances').text.to_i
        exclusions = result_node.at_xpath('performance-exclusion-instances').text.to_i
        antinumerator = result_node.at_xpath('performance-not-met-instances').text.to_i
        denominator = numerator + antinumerator

        # TODO: we need to figure out how to report errors like the PQRI not containing the same
        # measure IDs as designated by the product when it was created
        results[key] = {'denominator' => denominator, 'numerator' => numerator, 'exclusions' => exclusions, 'antinumerator' => antinumerator} if key
      end

      return results
    end

    # Validate the pqri submission against the xsd.
    #
    # Return value is an array of all errors found.
    def self.validate(doc)
      doc = (doc.kind_of? String) ? Nokogiri::XML::Document.new(doc) : doc
      validation_errors = []

      version = doc.xpath("/submission/@version").to_s
      
      unless SCHEMA_VERSIONS[version]
        return ["Schema Not avaialble for version #{version} to validate against"]
      end
      
      schema = Nokogiri::XML::Schema(open(Rails.root.join("public",SCHEMA_VERSIONS[version])))

      schema.validate(doc).each do |error|
        validation_errors << error.message
      end

      return validation_errors
    end
  end
end