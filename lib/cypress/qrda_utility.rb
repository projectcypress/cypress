require 'validators/schema_validator'
require 'validators/schematron_validator'
module Cypress
  class QrdaUtility
    QRDA_CAT1_ROOT="./resources/qrda_cat_1"
    QRDA_CAT1_SCHEMA_VALIDATOR = Validators::Schema::Validator.new("QRDA Cat I schema validator", "#{QRDA_CAT1_ROOT}/qrda_cat_1.xsd")
    QRDA_CAT1_SCHEMATRON_VALIDATOR = Validators::Schematron::CompiledValidator.new("QRDA Cat I schema validator",  "#{QRDA_CAT1_ROOT}/qrda_cat_1.xsl")
    MEASURE_VALIDATORS = {}
    # Extract and return measure results from a QRDA CATIII document and add to the reported results
    # for this test.
    def self.extract_results(doc)
      doc = (doc.kind_of? String )? Nokogiri::XML(doc) : doc
      #the nodes we want will have a child "templateId" with root = 2.16.840.1.113883.10.20.27.3.1
      xpath_results = '/xmlns:ClinicalDocument/xmlns:component/xmlns:structuredBody/xmlns:component/xmlns:section/xmlns:entry/xmlns:organizer/xmlns:templateId[@root = "2.16.840.1.113883.10.20.27.3.1"]/parent::*'
      xpath_measure_id = 'xmlns:reference/xmlns:externalDocument/xmlns:id'
      xpath_set_id = 'xmlns:reference/xmlns:externalDocument/xmlns:setId'
      
      results ||= {}
      result_nodes = doc.xpath(xpath_results)
      result_nodes.each do |result_node|
        measure_data = get_measure_data(result_node)
        measure_data[:measure_id] = result_node.at_xpath(xpath_measure_id)['root']
        measure_data[:set_id] = result_node.at_xpath(xpath_set_id)['root']
        keys = generate_keys(measure_data)
        results.merge!(populate_results(keys, measure_data))
      end
      results
    end

    def self.validate_cat3(file)
	    []
    end


    def self.validate_cat_1(file,measures=[])
      file_errors = []
      doc = Nokogiri::XML(data)

       # validate that each file in the zip contains a valid QRDA Cat I document.
       # We may in the future have to support looking in the contents of the test 
       # patient records to match agaist QRDA Cat I documents
       
       # First validate the schema correctness
       
        file_errors.concat QRDA_CAT1_SCHEMA_VALIDATOR.validate(doc, {msg_type: :error})

        file_errors.concat QRDA_CAT1_SCHEMATRON_VALIDATOR.validate(doc, {phase: :errors, msg_type: :error, file_name: name})
        file_errors.concat QRDA_CAT1_SCHEMATRON_VALIDATOR.validate(doc, {phase: :errors, msg_type: :warning, file_name: name })
        
        measures.each do |measure|
           schematron_validator = get_schematron_measure_validator(measure)
           file_errors.concat schematron_validator.validate(entry, {phase: :errors, msg_type: :error})
           file_errors.concat schematron_validator.validate(entry, {phase: :errors, msg_type: :warning }) 
        end

        file_errors
    end
    
    private
    
    def self.get_schematron_measure_validator(measure)
      MEASURE_VALIDATORS[measure.key] ||= Validators::Schematron::CompiledValidator.new("Schematron #{measure.key} Measure Validator", "#{QRDA_CAT1_ROOT}/#{measure.hqmf_id.downcase}.xslt")
    end

    #given a set of keys and the measure data, build a hash mapping the keys to the right data
    def self.populate_results(keys, mdata)
      results = {}
      keys.each do |k|
        result = {}
        k.each do |field, reference|
          load_value(mdata, k, field, result)
        end
        load_value(mdata, k, :excep, result)
        load_value(mdata, k, :denex, result)
        load_value(mdata, k, :numex, result)

        if result[:ipp]
          strata_hash = mdata[:ipp][k[:ipp]][:strata]
        elsif result[:msr_popl]
          strata_hash = mdata[:msr_popl][k[:msr_popl]][:strata]
          continuous_values = mdata[:msr_popl][k[:msr_popl]][:continuous_values]
        end

        if strata_hash
          result[:strata] = strata_hash[k[:strata]]
        end
        if continuous_values
          result[:continuous_values] = continuous_values
        end

        results[k] = result
      end
      results
    end

    def self.load_value(mdata, key, field, result)
      exceptions = [:excep,:denex,:numex]
      ignore = [:measure_id, :set_id, :strata]

      if ignore.include?(field)
        return
      elsif exceptions.include?(field)
        result[field] = mdata[field].values[0][:value] if mdata[field]
      else
        result[field] = mdata[field][key[field]][:value] if key[field]
      end
    end

    #given the measure data pulled from the QRDA, return hash of arrays of reference ids for the fields
    #assumes only measure populations and initial patient populations will have strata,
    #and a measure will only have at most 1 measure population and 1 initial patient population
    #TODO build this stuff when getting data from qrda?
    def self.get_ids(measure_data)
      #delete the measure_id and set_id because they dont follow the same patterns as the rest of the data
      ids = {measure_id:[measure_data.delete(:measure_id)], set_id:[measure_data.delete(:set_id)]}
      measure_data.each do |name, data|
        if name == :ipp || name == :msr_popl
          if data.nil?
            entry = {id:[''], strata:['']}
          else
            data.each do |ref, d|
              entry = {id: [ref], strata: ['']} 
              if d[:strata]
                entry[:strata] = []
                d[:strata].each do |ref_s, data_s|
                  entry[:strata] << ref_s
                end
              end
            end
          end
        else
          if data.nil?
            entry = ['']
          else
            entry = []
            data.each do |ref, d|
                entry << ref
            end
          end
        end
        ids[name] = entry
      end
      ids
    end

    def self.generate_keys(mdata)
      key_fields = [:measure_id, :set_id, :ipp, :msr_popl, :den, :num, :strata]
      keys = []
      ids = get_ids(mdata)
      ipp_ids = [ids[:measure_id], ids[:set_id], ids[:ipp][:id], [''], ids[:den], ids[:num], ids[:ipp][:strata]]
      msr_popl_ids = [ids[:measure_id], ids[:set_id], [''], ids[:msr_popl][:id], ids[:den], ids[:num], ids[:msr_popl][:strata]]

      permutations = generate_permutations(ipp_ids) + generate_permutations(msr_popl_ids)
      permutations.each do |p|
        new_key = {}
        key_fields.each do |field|
          val = p.shift
          new_key[field] = val if val!=""
        end
        keys << new_key
      end
      keys
    end

    def self.generate_permutations(ref_array)
      if ref_array.size == 1
        return ref_array[0]
      end
      top = ref_array.shift
      return top.product(generate_permutations(ref_array)).map {|x| x.flatten}
    end

    def self.get_measure_data(measure_node)
      code_mapping = {'NUMER' => :num, 'DENOM' => :den,'IPP' => :ipp, 'MSRPOPL' => :msr_popl , \
                      'NUMEX' => :numex, 'DENEX' => :denex,'EXCEP' => :excep}

      measure_data = {}
      code_mapping.each do |code, name|
        entry_list = {}
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
          reference = get_reference(n)
          list_stratum = get_strata(n)
          list_continuous_val = get_continuous_values(n)
          entry[:value] = convert_value(value_node) if value_node
          entry[:strata] = list_stratum if list_stratum
          entry[:continuous_values] = list_continuous_val if list_continuous_val
          
          entry_list[reference] = entry
        end
        entry_list = nil if entry_list.empty?
        measure_data[name] = entry_list
      end
      measure_data
    end

    #get all continuous values within a measure data (numerator, denominator, etc) node
    def self.get_continuous_values(node)
      xpath_observations = 'xmlns:entryRelationship[@typeCode="COMP"]/xmlns:templateId[@root = "2.16.840.1.113883.10.20.27.3.2"]/following-sibling::xmlns:observation'
      xpath_expected = 'xmlns:referenceRange/xmlns:observationRange/xmlns:value'
      xpath_code  = 'xmlns:methodCode'
      xpath_value = 'xmlns:value'
      
      list_values = {}
      observation_nodes = node.xpath(xpath_observations)
      observation_nodes.each do |n|
        entry = {}
        entry['code']  = n.at_xpath(xpath_code)['code']
        entry['unit']  = n.at_xpath(xpath_value)['unit']
        entry['value'] = convert_value(n.at_xpath(xpath_value))
        list_values[get_reference(n)] = entry
      end
      list_values = nil if list_values.empty?
      list_values
    end

    def self.get_strata(node)
      template_id = '2.16.840.1.113883.10.20.27.3.4'
      xpath_observations = 'xmlns:entryRelationship[@typeCode="COMP"]/xmlns:observation/xmlns:templateId[@root = "'+ template_id +'"]/parent::*'

      observation_nodes = node.xpath(xpath_observations)
      list_stratum = {}
      observation_nodes.each do |n|
        list_stratum[get_reference(n)] = get_aggregate_count(n)
      end

      list_stratum = nil if list_stratum.empty?
      list_stratum
    end

    #given an observation node with an aggregate count node, return the reported and expected value within the count node
    def self.get_aggregate_count(node)
      xpath_value = 'xmlns:entryRelationship/xmlns:observation/xmlns:value'
      xpath_expected = 'xmlns:entryRelationship/xmlns:observation/xmlns:referenceRange/xmlns:observationRange/xmlns:value'

      value_node = node.at_xpath(xpath_value)
      value = convert_value(value_node) if value_node
      value ||= ''
    end

    #given an observation node with a reference, gets the reference 
    def self.get_reference(node)
      xpath_reference = 'xmlns:reference/xmlns:externalObservation/xmlns:id'
      reference_node  =  node.at_xpath(xpath_reference)
      reference = reference_node['root'] if reference_node
      reference ||= ''
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