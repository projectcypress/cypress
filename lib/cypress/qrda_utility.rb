module Cypress
  class QrdaUtility
  

    # Extract and return measure results from a QRDA CATIII document and add to the reported results
    # for this test.
    def self.extract_results(doc)
      doc = (doc.kind_of? String )? Nokogiri::XML::Document.new(doc) : doc
      #the nodes we want will have a child "templateId" with root = 2.16.840.1.113883.10.20.27.3.1
      xpath_results = '/xmlns:ClinicalDocument/xmlns:component/xmlns:structuredBody/xmlns:component/xmlns:section/xmlns:entry/xmlns:organizer/xmlns:templateId[@root = "2.16.840.1.113883.10.20.27.3.1"]/parent::*'
      xpath_measure_key = 'xmlns:reference/xmlns:externalDocument/xmlns:id[@root = "2.16.840.1.113883.3.560.1"]'
      
      results ||= {}
      result_nodes = doc.xpath(xpath_results)
      result_nodes.each do |result_node|
        key = result_node.at_xpath(xpath_measure_key)['extension']
        results[key] = get_measure_data(result_node) if key
      end

      results
    end

    def self.validate_cat3_document(file)
	    
    end

    def self.validate_zip(file)
      file_errors = {}
      Zip::ZipFile.open(file.path) do |zipfile|
       zipfile.entries.each do |entry|
        file_errors[entry.name] = []
         # validate that each file in the zip contains a valid QRDA Cat I document.
         # We may in the future have to support looking in the contents of the test 
         # patient records to match agaist QRDA Cat I documents
         
         # First validate the schema correctness
          schema_validator = get_schema_validator
          file_errors[entry.name].concat schema_validator.validate(entry, msg_type: :error)
          
          schematron_validator = get_schematron_validator
          file_errors[entry.name].concat schematron_validator.validate(entry, {phase: :errors}, msg_type: :error)
          file_errors[entry.name].concat schematron_validator.validate(entry, {phase: :errors}, msg_type: :warning )
            
       end
     end
     file_errors
    end

    private

    def self.get_measure_data(measure_node)
      code_mapping = {'NUMER' => 'numerator', 'DENOM' => 'denominator','IPP' => 'initial_population', 'MSRPOPL' => 'measure_population' , \
                      'NUMEX' => 'numerator_exclusions', 'DENEX' => 'denominator_exclusions','EXCEP' => 'denominator_exceptions'}
      race_code   = '2.16.840.1.113883.10.20.27.3.8'
      gender_code = '2.16.840.1.113883.10.20.27.3.6'
      ethnic_code = '2.16.840.1.113883.10.20.27.3.7'

      measure_data = {}
      get_rates(measure_node,measure_data)
      code_mapping.each do |code, name|
        entry_list = []
        xpath_value    = 'xmlns:observation/xmlns:value'
        xpath_expected = 'xmlns:observation/xmlns:referenceRange/xmlns:observationRange/xmlns:value'
        xpath_observations = 'xmlns:component/xmlns:observation/xmlns:value[@code = "'+ code +'"]/parent::*'
        xpath_entryRelationship = 'xmlns:value[@code = "'+ code +'"]/following-sibling::xmlns:entryRelationship'

        observation_nodes = measure_node.xpath(xpath_observations)
        observation_nodes.each do |n|
          entry_node = n.at_xpath(xpath_entryRelationship)
          value_node = entry_node.at_xpath(xpath_value)
          expected_value_node = entry_node.at_xpath(xpath_expected)

          entry = {}
          entry['value'] = convert_value(value_node) if value_node
          entry['expected_value'] = convert_value(expected_value_node) if expected_value_node
          get_reference(entry_node, entry)

          list_race   = get_demographics_data(n,race_code)
          list_gender = get_demographics_data(n,gender_code)
          list_ethnicity = get_demographics_data(n,ethnic_code)
          list_stratum = get_stratum(n)
          list_continuous_val = get_continuous_values(n)
          
          entry['race'] = list_race if list_race
          entry['gender']  = list_gender  if list_gender
          entry['stratum'] = list_stratum if list_stratum
          entry['ethnicity'] = list_ethnicity if list_ethnicity
          entry['continuous_values'] = list_continuous_val if list_continuous_val
          
          entry_list << entry
        end
        entry_list = '' if entry_list.empty?
        measure_data[name] = entry_list
      end
      measure_data
    end

    #Get performance rate and reporting rate if they exist
    def self.get_rates(node, entry)
      code_mapping = {'2.16.840.1.113883.10.20.27.3.14' => 'performance_rate', '2.16.840.1.113883.10.20.27.3.15' => 'reporting_rate'}

      code_mapping.each do |template_id, name|
        xpath_observation   = 'xmlns:component/xmlns:observation/xmlns:templateId[@root="'+template_id+'"]/..'
        xpath_expected_rate = 'xmlns:referenceRange/xmlns:observationRange/xmlns:value'
        xpath_rate = 'xmlns:value'

        rate = {}
        observation_node = node.at_xpath(xpath_observation)
        if observation_node.nil?
          next
        end
        rate_node = observation_node.at_xpath(xpath_rate)
        expected_node = observation_node.at_xpath(xpath_expected_rate)
        rate['value']    = convert_value(rate_node) if !rate_node.nil?
        rate['expected'] = convert_value(expected_node) if !expected_node.nil?
        entry[name] = rate if !rate.empty?
      end
      entry
    end

    #get all continuous values within a measure data (numerator, denominator, etc) node
    def self.get_continuous_values(node)
      xpath_observations = 'xmlns:entryRelationship[@typeCode="COMP"]/xmlns:templateId[@root = "2.16.840.1.113883.10.20.27.3.2"]/following-sibling::xmlns:observation'
      xpath_expected = 'xmlns:referenceRange/xmlns:observationRange/xmlns:value'
      xpath_code  = 'xmlns:methodCode'
      xpath_value = 'xmlns:value'
      
      list_values = []
      observation_nodes = node.xpath(xpath_observations)
      observation_nodes.each do |n|
        entry = get_reference(n,{})
        entry['code']  = n.at_xpath(xpath_code)['code']
        entry['unit']  = n.at_xpath(xpath_value)['unit']
        entry['value'] = convert_value(n.at_xpath(xpath_value))
        entry['expected']  = convert_value(n.at_xpath(xpath_expected))
        list_values << entry
      end
      list_values = nil if list_values.empty?
      list_values
    end

    #get gender, race, or ethnicity data when given one of the three corresponding template IDs
    def self.get_demographics_data(node,template_id)
      xpath_data = 'xmlns:entryRelationship[@typeCode="COMP"]/xmlns:observation/xmlns:templateId[@root = "'+ template_id +'"]/parent::*'
      result_nodes = node.xpath(xpath_data)

      list_data = {}
      result_nodes.each do |n|
        data_code = n.at_xpath('xmlns:value')['code']
        list_data[data_code] = get_aggregate_count(n, {})
      end

      list_data = nil if list_data.empty?
      list_data     
    end

    def self.get_stratum(node)
      template_id = '2.16.840.1.113883.10.20.27.3.4'
      xpath_observations = 'xmlns:entryRelationship[@typeCode="COMP"]/xmlns:observation/xmlns:templateId[@root = "'+ template_id +'"]/parent::*'

      observation_nodes = node.xpath(xpath_observations)
      list_stratum = []
      observation_nodes.each do |n|
        stratum = get_reference(n, {})
        stratum = get_aggregate_count(n, stratum)
        list_stratum << stratum
      end

      list_stratum = nil if list_stratum.empty?
      list_stratum
    end

    #given an observation node with an aggregate count node, return the reported and expected value within the count node
    def self.get_aggregate_count(node, entry)
      xpath_value = 'xmlns:entryRelationship/xmlns:observation/xmlns:value'
      xpath_expected = 'xmlns:entryRelationship/xmlns:observation/xmlns:referenceRange/xmlns:observationRange/xmlns:value'

      value_node    = node.at_xpath(xpath_value)
      expected_node = node.at_xpath(xpath_expected)

      entry['value']= convert_value(value_node) if !value_node.nil?
      entry['expected'] = convert_value(expected_node) if expected_node
      return entry
    end

    #given an observation node with a reference, gets the reference 
    def self.get_reference(node, entry)
      xpath_reference = 'xmlns:reference/xmlns:externalObservation/xmlns:id'
      reference_node  =  node.at_xpath(xpath_reference)
      entry['reference'] = reference_node['root'] if reference_node
      return entry
    end

    #convert numbers in value nodes to Int / Float as necessary TODO add more types other than 'REAL'
    def self.convert_value(value_node)
      if value_node.nil?
          return
      end
      if value_node['type'] == 'REAL' || value_node['value'].include?('.')
        return value_node['value'].to_f
      else
        return value_node['value'].to_i
      end
    end

  end
end