require 'validators/schema_validator'
require 'validators/schematron_validator'
module Cypress
  class QrdaUtility
    QRDA_CAT1_SCHEMATRON_CONFIG = APP_CONFIG["validation"]["schematron"]["qrda_cat_1"]
    QRDA_CAT1_SCHEMATRON_ROOT= QRDA_CAT1_SCHEMATRON_CONFIG["root"]
    QRDA_CAT1_SCHEMA_VALIDATOR = Validators::Schema::Validator.new("QRDA Cat I schema validator", APP_CONFIG["validation"]["schema"]["qrda_cat_1"])
    QRDA_CAT1_SCHEMATRON_VALIDATOR = Validators::Schematron::CompiledValidator.new("Generic QRDA Cat I Schematron", File.join(QRDA_CAT1_SCHEMATRON_ROOT, QRDA_CAT1_SCHEMATRON_CONFIG["generic"]) )
    MEASURE_VALIDATORS = {}


    # Validates a QRDA Cat I file.  This routine will validate the file against the CDA schema as well as the 
    # Generic QRDA Cat I scheamtron rules and the measure specific rules for each of the measures passed in.
    # THe result will be an Array of execution errors or an empty array if there were no errors.
    def self.validate_cat_1(data, measures=[], name="")

      file_errors = []
      doc = Nokogiri::XML(data)

       # validate that each file in the zip contains a valid QRDA Cat I document.
       # We may in the future have to support looking in the contents of the test 
       # patient records to match agaist QRDA Cat I documents
       
       # First validate the schema correctness
        file_errors.concat QRDA_CAT1_SCHEMA_VALIDATOR.validate(doc, {msg_type: :error}) 

        # Valdiate aginst the generic schematron rules
        file_errors.concat QRDA_CAT1_SCHEMATRON_VALIDATOR.validate(doc, {phase: :errors, msg_type: :error, file_name: name})
        file_errors.concat QRDA_CAT1_SCHEMATRON_VALIDATOR.validate(doc, {phase: :errors, msg_type: :warning, file_name: name })
        
        # validate the mesure specific rules
        measures.each do |measure|
           schematron_validator = get_schematron_measure_validator(measure)
           if schematron_validator 
            file_errors.concat schematron_validator.validate(doc, {phase: :errors, msg_type: :error, measure_id: measure.key})
            file_errors.concat schematron_validator.validate(doc, {phase: :warning, msg_type: :warning ,measure_id: measure.key }) 
          end
        end

        file_errors
    end
    
    private


    def self.get_schematron_measure_validator(measure)
      fname = File.join(QRDA_CAT1_SCHEMATRON_ROOT,QRDA_CAT1_SCHEMATRON_CONFIG["measure_specific_dir"],"#{measure.hqmf_id.downcase}.xslt" ) #{APP_CONFIG["validation"]["qrda"]["qrda_cat_1"]["measure_specific_dir"]}/#{measure.hqmf_id.downcase}.xslt"
      if File.exists?(fname)
        return MEASURE_VALIDATORS[measure.hqmf_id] ||= Validators::Schematron::CompiledValidator.new("Schematron #{measure.hqmf_id} Measure Validator", fname)
      end
    end


    # Extract and return measure results from a QRDA CATIII document and add to the reported results
    # for this test.
    def self.extract_results(doc)
      doc = (doc.kind_of? String )? Nokogiri::XML(doc) : doc
      doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
      #the nodes we want will have a child "templateId" with root = 2.16.840.1.113883.10.20.27.3.1
      xpath_measures = '/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/cda:entry/cda:organizer/cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.1"]/parent::*'
      
      results ||= {}
      result_nodes = doc.xpath(xpath_measures)
      result_nodes.each do |result_node|
        results.merge!(extract_measure_results(result_node))
      end
      results
    end

    #takes a document and a list of 1 or more id hashes, e.g.:
    #[{measure_id:"8a4d92b2-36af-5758-0136-ea8c43244986", set_id:"03876d69-085b-415c-ae9d-9924171040c2", ipp:"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", den:"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", num:"9363135E-A816-451F-8022-96CDA7E540DD"}]
    #returns nil if nothing matching is found 
    # returns a hash with the values of the populations filled out along with the population_ids added to the result 
    def self.extract_results_by_ids(doc, measure_id,  ids)
      doc = (doc.kind_of? String )? Nokogiri::XML(doc) : doc
      doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
      results = nil
      _ids = ids.dup
      stratification = _ids.delete(:stratification)
        
      find_measure_nodes(doc,measure_id).each do |n|
        entry = {}
        _ids.each_pair do |k,v|
          val = extract_component_value(n,k,v,stratification)
          if val.nil?
            entry = nil
            break
          end
          entry[k.to_s] = val

        end
        if entry
          results = entry 
          break
        end
      end  
      return nil unless results

       code_mapping = {'NUMER' => :numerator, 'DENOM' => :denominator,'IPP' => :population, 'MSRPOPL' => :msr_popl , 
                      'NUMEX' => :numex, 'DENEX' => :exclusions,'DENEXCEP' => :exceptions}
        if results
          code_mapping.each_pair do |k,v|
            if results[k]
              results[v] = results[k]
              results.delete(k)
            end
        end
      end
      results[:population_ids] = ids.dup
      results
    end


  def self.find_measure_nodes(doc,id)
     xpath_measures = %{/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/cda:entry/cda:organizer[ ./cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.1"] and ./cda:reference/cda:externalDocument/cda:id[#{translate("@root")}='#{id.upcase}']] }
     return doc.xpath(xpath_measures)  || []
  end

  def self.translate(id)
    %{translate(#{id}, "abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ")}
  end


  def self.extract_component_value(node, code,id,strata = nil)
    xpath_observation = %{ cda:component/cda:observation[./cda:value[@code = "#{code}"] and ./cda:reference/cda:externalObservation/cda:id[#{translate("@root")}='#{id.upcase}']]}
    cv = node.at_xpath(xpath_observation)
    return nil unless cv
    val = nil
    if strata
       strata_path = %{ cda:entryRelationship[@typeCode="COMP"]/cda:observation[./cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.4"]  and ./cda:reference/cda:externalObservation/cda:id[#{translate("@root")}='#{strata.upcase}']]}
       n = cv.xpath(strata_path)
       val = get_aggregate_count(n) if n
    else
      val = get_aggregate_count(cv)
    end
    return val
  end




    def self.validate_cat3(file)
	    []
    end


    

    #checks if a hash of values has a value for every field in a key
    def self.check_result(keys, values)
      keys.each do |name, ref|
        #skip special case of measure ids
        next if name == :measure_id || name == :set_id
        return false if values[name].nil?
      end
      true
    end

    #extract all the data from a measure node, keys is an optional list of
    #key hashes. if not given, will create all possible key permutations based on the measure data
    def self.extract_measure_results(measure_node, keys = nil)
      xpath_measure_id = 'cda:reference/cda:externalDocument/cda:id'
      xpath_set_id = 'cda:reference/cda:externalDocument/cda:setId'

      measure_data = get_measure_data(measure_node)
      measure_data[:measure_id] = measure_node.at_xpath(xpath_measure_id)['root']
     # measure_data[:set_id] = measure_node.at_xpath(xpath_set_id)['root']
      keys = generate_keys(measure_data) if keys.nil?
      results = populate_results(keys, measure_data)

      ## this is here to map this to what is really needed.  THe code below that handles this needs
      # to be refactored and is just way more complicated than it needs to be.  This is a simple stop
      # gap without needing to go in and figure out what that is doing.
      res = {}
      results.each_pair do |k,v|
        code_mapping = {'NUMER' => :num, 'DENOM' => :den,'IPP' => :ipp, 'MSRPOPL' => :msr_popl , 
                      'NUMEX' => :numex, 'DENEX' => :denex,'EXCEP' => :excep, "stratification" => :strata}
        nkey = {}             
        code_mapping.each_pair do |code,name|
          k.delete(:set_id)
          if k[name]
            k[code] = k[name]
            k.delete(name)
          end
        end

        {den: :denominator, num: :numerator}.each_pair do |old,n|
          if v[old]
            v[n] = v[old]
            v.delete(old)
          end

        end

      end

      results
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

        #This code will alter the key to add all the continuous values
        if continuous_values
          continuous_values.each do |reference,values|
            code = values['code'].to_sym
            k[code] = reference
            result[code] = values['value']
          end
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
        result[field] = mdata[field][key[field]][:value] if mdata[field] && mdata[field][key[field]]
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
      key_fields = [:measure_id, :set_id, :ipp, :msr_popl, :den,  :num, :denex, :numex, :excep,:strata]
      keys = []
       
      ids = get_ids(mdata)
      ipp_ids = [ids[:measure_id], ids[:set_id], ids[:ipp][:id], [''], ids[:den], ids[:num], ids[:denex], ids[:numex],  ids[:excep], ids[:ipp][:strata]]
      msr_popl_ids = [ids[:measure_id], ids[:set_id], [''], ids[:msr_popl][:id], ids[:den], ids[:num],ids[:denex], ids[:numex],  ids[:excep], ids[:msr_popl][:strata]]

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
        xpath_value    = 'cda:observation/cda:value'
        xpath_expected = 'cda:observation/cda:referenceRange/cda:observationRange/cda:value'
        xpath_observations = 'cda:component/cda:observation/cda:value[@code = "'+ code +'"]/parent::*'
        xpath_entryRelationship = 'cda:value[@code = "'+ code +'"]/following-sibling::cda:entryRelationship'

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
      binding
      measure_data
    end

    #get all continuous values within a measure data (numerator, denominator, etc) node
    def self.get_continuous_values(node)
      xpath_observations = 'cda:entryRelationship[@typeCode="COMP"]/cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.2"]/following-sibling::cda:observation'
      xpath_expected = 'cda:referenceRange/cda:observationRange/cda:value'
      xpath_code  = 'cda:methodCode'
      xpath_value = 'cda:value'
      
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
      xpath_observations = 'cda:entryRelationship[@typeCode="COMP"]/cda:observation/cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.4"]/parent::*'

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
      xpath_value = 'cda:entryRelationship/cda:observation[./cda:templateId[@root="2.16.840.1.113883.10.20.27.3.3"]]/cda:value'
      
      value_node = node.at_xpath(xpath_value)
      value = convert_value(value_node) if value_node
      value
    end

    #given an observation node with a reference, gets the reference 
    def self.get_reference(node)
      xpath_reference = 'cda:reference/cda:externalObservation/cda:id'
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