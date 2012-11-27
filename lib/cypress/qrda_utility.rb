require 'validators/schema_validator'
require 'validators/schematron_validator'
module Cypress
  class QrdaUtility


    POPULATION_CODE_MAPPINGS = {'NUMER' => "numerator", 'DENOM' => "denominator",'IPP' => "population", 'MSRPOPL' => "msr_popl" , 
                      'NUMEX' => "numex", 'DENEX' => "exclusions",'DENEXCEP' => "exceptions", 'EXCEP' => "exceptions"}

    
    CV_METHOD_CODES = ["OBSRV", "COUNT","SUM", "AVERAGE","STDEV.S","VARIANCE.S","STDEV.P","VARIANCE.P","MIN","MAX", "MEDIAN", "MODE"]
    CV_POPULATION_CODE = "OBSRV"
    
    QRDA_CAT1_SCHEMATRON_CONFIG = APP_CONFIG["validation"]["schematron"]["qrda_cat_1"]
    QRDA_CAT3_SCHEMATRON_CONFIG = APP_CONFIG["validation"]["schematron"]["qrda_cat_3"]
    QRDA_CAT1_SCHEMATRON_ROOT= QRDA_CAT1_SCHEMATRON_CONFIG["root"]
    QRDA_CAT3_SCHEMATRON_ROOT= QRDA_CAT3_SCHEMATRON_CONFIG["root"]

    #QRDA_CAT1_SCHEMA_VALIDATOR = Validators::Schema::Validator.new("QRDA Cat I schema validator", APP_CONFIG["validation"]["schema"]["qrda_cat_1"])
    QRDA_CAT1_SCHEMATRON_ERROR_VALIDATOR = Validators::Schematron::CompiledValidator.new("Generic QRDA Cat I Schematron", File.join(QRDA_CAT1_SCHEMATRON_ROOT, QRDA_CAT1_SCHEMATRON_CONFIG["generic_error"]) )
    QRDA_CAT1_SCHEMATRON_WARNING_VALIDATOR = Validators::Schematron::CompiledValidator.new("Generic QRDA Cat I Schematron", File.join(QRDA_CAT1_SCHEMATRON_ROOT, QRDA_CAT1_SCHEMATRON_CONFIG["generic_warning"]) )
    
    QRDA_CAT3_SCHEMATRON_ERROR_VALIDATOR = Validators::Schematron::CompiledValidator.new("Generic QRDA Cat III Schematron", File.join(QRDA_CAT3_SCHEMATRON_ROOT, QRDA_CAT3_SCHEMATRON_CONFIG["generic_error"]) )
    QRDA_CAT3_SCHEMATRON_WARNING_VALIDATOR = Validators::Schematron::CompiledValidator.new("Generic QRDA Cat III Schematron", File.join(QRDA_CAT3_SCHEMATRON_ROOT, QRDA_CAT3_SCHEMATRON_CONFIG["generic_warning"]) )
    
    MEASURE_VALIDATORS = {}


    # Validates a QRDA Cat I file.  This routine will validate the file against the CDA schema as well as the 
    # Generic QRDA Cat I scheamtron rules and the measure specific rules for each of the measures passed in.
    # THe result will be an Array of execution errors or an empty array if there were no errors.
    def self.validate_cat_1(data, measures=[], name="")

      file_errors = []
      doc = Nokogiri::XML(data)
      doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
       # validate that each file in the zip contains a valid QRDA Cat I document.
       # We may in the future have to support looking in the contents of the test 
       # patient records to match agaist QRDA Cat I documents
       
       # First validate the schema correctness
      #file_errors.concat QRDA_CAT1_SCHEMA_VALIDATOR.validate(doc, {msg_type: :error}) 

        # Valdiate aginst the generic schematron rules
        file_errors.concat QRDA_CAT1_SCHEMATRON_ERROR_VALIDATOR.validate(doc, {phase: :errors, msg_type: :error, file_name: name})
        file_errors.concat QRDA_CAT1_SCHEMATRON_WARNING_VALIDATOR.validate(doc, {phase: :errors, msg_type: :warning, file_name: name })
        
        # validate the mesure specific rules
        measures.each do |measure|
           schematron_validator = get_schematron_measure_validator(measure)
           if schematron_validator 
            #file_errors.concat schematron_validator.validate(doc, {phase: :errors, msg_type: :error, measure_id: measure.key})
            file_errors.concat schematron_validator.validate(doc, {phase: :warning, msg_type: :warning ,measure_id: measure.key }) 
          end

          # Look in the document to see if there is an entry stating that it is reporting on the given measure
          # we will be a bit lieniant and look for both the version specific id and the non version specific ids

          if !doc.at_xpath("//cda:organizer[./templateId[@root='2.16.840.1.113883.10.20.24.3.98']]/cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode='DOC']/cda:id[#{translate("@root")}='#{measure.hqmf_id.upcase}']")
            file_errors << ExecutionError.new(:location=>"/", :msg_type=>"error", :message=>"Document does not state it is reporting measure #{measure.hqmf_id}  - #{measure.name}")
          end
        end

        file_errors
    end
    
    private


    def self.get_schematron_measure_validator(measure)
      fname = File.join(QRDA_CAT1_SCHEMATRON_ROOT,QRDA_CAT1_SCHEMATRON_CONFIG["measure_specific_dir"],"#{measure.hqmf_set_id.downcase}.xslt" ) #{APP_CONFIG["validation"]["qrda"]["qrda_cat_1"]["measure_specific_dir"]}/#{measure.hqmf_id.downcase}.xslt"
      if File.exists?(fname)
        return MEASURE_VALIDATORS[measure.hqmf_id] ||= Validators::Schematron::CompiledValidator.new("Schematron #{measure.hqmf_set_id} Measure Validator", fname)
      end
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
      stratification = _ids.delete("stratification")
        
      find_measure_nodes(doc,measure_id).each do |n|
        entry = {}
        _ids.each_pair do |k,v|
          val = nil
          if (k == CV_POPULATION_CODE)
            msrpopl = _ids["MSRPOPL"]
            val = extract_cv_value(n,v,msrpopl, stratification)
          else 
            val =extract_component_value(n,k,v,stratification)
          end

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

        if results
          POPULATION_CODE_MAPPINGS.each_pair do |k,v|
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



  def self.extract_cv_value(node,id,msrpopl, strata = nil)
     xpath_observation = %{ cda:component/cda:observation[./cda:value[@code = "MSRPOPL"] and ./cda:reference/cda:externalObservation/cda:id[#{translate("@root")}='#{msrpopl.upcase}']]}
     cv = node.at_xpath(xpath_observation)
     return nil unless cv
     val = nil
     if strata
       strata_path = %{ cda:entryRelationship[@typeCode="COMP"]/cda:observation[./cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.4"]  and ./cda:reference/cda:externalObservation/cda:id[#{translate("@root")}='#{strata.upcase}']]}
       n = cv.xpath(strata_path)
       val = get_cv_value(n)
     else
       val = get_cv_value(cv)
     end
    return val
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



    # Nothing to see here - Move along
    def self.validate_cat3(data)
      doc = Nokogiri::XML(data)
      doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")

	    file_errors = []
      # Valdiate aginst the generic schematron rules
      file_errors.concat QRDA_CAT3_SCHEMATRON_ERROR_VALIDATOR.validate(doc, {phase: :errors, msg_type: :error, file_name: name})
      file_errors.concat QRDA_CAT3_SCHEMATRON_WARNING_VALIDATOR.validate(doc, {phase: :errors, msg_type: :warning, file_name: name })
      file_errors
    end


    #given an observation node with an aggregate count node, return the reported and expected value within the count node
    def self.get_cv_value(node)
      xpath_value = 'cda:entryRelationship/cda:observation[./cda:templateId[@root="2.16.840.1.113883.10.20.27.3.2"]]/cda:value'
      
      value_node = node.at_xpath(xpath_value)
      value = convert_value(value_node) if value_node
      value
    end


    #given an observation node with an aggregate count node, return the reported and expected value within the count node
    def self.get_aggregate_count(node)
      xpath_value = 'cda:entryRelationship/cda:observation[./cda:templateId[@root="2.16.840.1.113883.10.20.27.3.3"]]/cda:value'
      
      value_node = node.at_xpath(xpath_value)
      value = convert_value(value_node) if value_node
      value
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