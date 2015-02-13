module Validators
  class ExpectedResultsValidator < QrdaFileValidator
    attr_accessor :reported_results

    def initialize(file, expected_results)
      @document = get_document(file)
      @expected_results = expected_results
      @reported_results = {}
    end

    # Nothing to see here - Move along
    def validate()
      validation_errors = []
      @expected_results.each_pair do |key,expected_result|
        result_key = expected_result["population_ids"].dup

        reported_result, errors = extract_results_by_ids(expected_result['measure_id'], result_key)
        @reported_results[key] = reported_result
        validation_errors.concat match_calculation_results(expected_result,reported_result)
      end

      validation_errors
    end

    private

      #takes a document and a list of 1 or more id hashes, e.g.:
    #[{measure_id:"8a4d92b2-36af-5758-0136-ea8c43244986", set_id:"03876d69-085b-415c-ae9d-9924171040c2", ipp:"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", den:"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", num:"9363135E-A816-451F-8022-96CDA7E540DD"}]
    #returns nil if nothing matching is found
    # returns a hash with the values of the populations filled out along with the population_ids added to the result
    def extract_results_by_ids(measure_id, ids)
      results = nil
      _ids = ids.dup
      stratification = _ids.delete("stratification")
      errors = []
      nodes = find_measure_node(measure_id)

      if nodes.nil? || nodes.empty?
        # short circuit and return nil
        return {}
      end

      nodes.each do |n|
       results =  get_measure_components(n, _ids, stratification)
       break if (results != nil || (results != nil && !results.empty?))
      end
      return nil if results.nil?
      results[:population_ids] = ids.dup
      results

    end

    def find_measure_node(id)
       xpath_measures = %Q{/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section
        /cda:entry/cda:organizer[ ./cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.1"]
        and ./cda:reference/cda:externalDocument/cda:id[#{translate("@extension")}='#{id.upcase}' and #{translate("@root")}='2.16.840.1.113883.4.738']]}
       return @document.xpath(xpath_measures)
    end

    def get_measure_components(n,ids, stratification)
      results = {:supplemental_data =>{}}
      ids.each_pair do |k,v|
        val = nil
        sup = nil
        if (k == CV_POPULATION_CODE)
          msrpopl = ids[QME::QualityReport::MSRPOPL]
          val, sup = extract_cv_value(n,v,msrpopl, stratification)
        else
          val,sup =extract_component_value(n,k,v,stratification)
        end

        if !val.nil?
          results[k.to_s] = val
          results[:supplemental_data][k] = sup
        else
          # return nil
        end
      end
      results
    end

    def extract_cv_value(node, id, msrpopl, strata = nil)
      xpath_observation = %{ cda:component/cda:observation[./cda:value[@code = "MSRPOPL"] and ./cda:reference/cda:externalObservation/cda:id[#{translate("@root")}='#{msrpopl.upcase}']]}
      cv = node.at_xpath(xpath_observation)
      return nil unless cv
      val = nil
      if strata
      strata_path = %{ cda:entryRelationship[@typeCode="COMP"]/cda:observation[./cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.4"]  and ./cda:reference/cda:externalObservation/cda:id[#{translate("@root")}='#{strata.upcase}']]}
      n = cv.xpath(strata_path)
      val = get_cv_value(n,id)
      else
      val = get_cv_value(cv,id)
      end
      return val, (strata.nil? ?  extract_supplemental_data(cv) : nil)
    end

    def extract_component_value(node, code, id, strata = nil)
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
      return val,(strata.nil? ?  extract_supplemental_data(cv) : nil)
    end

    # convert numbers in value nodes to Int / Float as necessary TODO add more types other than 'REAL'
    def convert_value(value_node)
      if value_node.nil?
        return
      end
      if value_node['type'] == 'REAL' || value_node['value'].include?('.')
        return value_node['value'].to_f
      else
        return value_node['value'].to_i
      end
    end

    #given an observation node with an aggregate count node, return the reported and expected value within the count node
    def get_cv_value(node, cv_id)
      xpath_value = %{cda:entryRelationship/cda:observation[./cda:templateId[@root="2.16.840.1.113883.10.20.27.3.2"] and ./cda:reference/cda:externalObservation/cda:id[#{translate("@root")}='#{cv_id.upcase}']]/cda:value}

      value_node = node.at_xpath(xpath_value)
      value = convert_value(value_node) if value_node
      value
    end

    #given an observation node with an aggregate count node, return the reported and expected value within the count node
    def get_aggregate_count(node)
      xpath_value = 'cda:entryRelationship/cda:observation[./cda:templateId[@root="2.16.840.1.113883.10.20.27.3.3"]]/cda:value'

      value_node = node.at_xpath(xpath_value)
      value = convert_value(value_node) if value_node
      value
    end

    def extract_supplemental_data(cv)
      ret = {}
      SUPPLEMENTAL_DATA_MAPPING.each_pair do |supp, id|
        key_hash = {}
        xpath = "cda:entryRelationship/cda:observation[cda:templateId[@root='#{id}']]"
        (cv.xpath(xpath) || []).each do |node|
          value = node.at_xpath('cda:value')
          count = get_aggregate_count(node)
          if value.at_xpath("./@nullFlavor")
           key_hash["UNK"] = count
          else
           key_hash[value['code']] = count
          end
        end
        ret[supp.to_s] = key_hash
      end
      ret
    end

    def match_calculation_results(expected_result, reported_result)
      validation_errors = []
      measure_id = expected_result["measure_id"]
      logger = -> (message, stratification) {
        validation_errors << ExecutionError.new(message: message, msg_type: :error, measure_id: measure_id,
                  validator_type: :result_validation, stratification: stratification)
      }

      check_for_reported_results_population_ids(expected_result, reported_result, logger)
      return validation_errors if validation_errors.present?

      _ids = expected_result["population_ids"].dup
      # remove the stratification entry if its there, not needed to test against values
      stratification = _ids.delete("stratification")
      logger_with_stratification = -> (message) {logger.call(message, stratification)}
      _ids.keys.each do |pop_key|
        if expected_result[pop_key].present?
          check_population(expected_result, reported_result, pop_key, stratification, logger)

          # Check supplemental data elements
          ex_sup = (expected_result["supplemental_data"] || {})[pop_key]
          reported_sup  = (reported_result[:supplemental_data] || {})[pop_key]
          if stratification.nil? && ex_sup

            sup_keys = ex_sup.keys.reject(&:blank?)
            # check to see if we expect sup data and if they provide it a short circuit the rest of the testing
            # if they do not
            if sup_keys.length>0 && reported_sup.nil?
              err = "supplemental data for #{pop_key} not found expected  #{ex_sup}"
              logger_with_stratification.call(err)
            else
              # for each supplemental data item (RACE, ETHNICITY,PAYER,SEX)
              sup_keys.each do |sup_key|
                sup_value  = (ex_sup[sup_key] || {}).reject{|k,v| (k.blank? || v.blank? || v=="UNK")}
                reported_sup_value = reported_sup[sup_key]
                check_supplemental_data(sup_value, reported_sup_value, pop_key, sup_key, logger_with_stratification)
              end
            end
          end
        end
      end

      validation_errors
    end

    def check_for_reported_results_population_ids(expected_result, reported_result, logger)
      _ids = expected_result["population_ids"].dup
      if reported_result.nil? || reported_result.keys.length <= 1
        message = "Could not find entry for measure #{expected_result["measure_id"]} with the following population ids "
        message +=  _ids.inspect
        logger.call(message, _ids['stratification'])
      end
    end

    def check_population(expected_result, reported_result, pop_key, stratification, logger)
      # only add the error that they dont match if there was an actual result
      if !reported_result.empty? && !reported_result.has_key?(pop_key)
        message = "Could not find value"
        message += " for stratification #{stratification} " if stratification
        message += " for Population #{pop_key}"
        logger.call(message, stratification)
      elsif (expected_result[pop_key] != reported_result[pop_key]) && !reported_result.empty?
        err = "expected #{pop_key} #{expected_result["population_ids"][pop_key]} value #{expected_result[pop_key]} does not match reported value #{reported_result[pop_key]}"
        logger.call(err, stratification)
      end
    end

    def check_supplemental_data(expected_supplemental_value, reported_supplemantal_value, population_key, supplemental_data_key, logger)
      if reported_supplemantal_value.nil?
        err = "supplemental data for #{population_key} #{supplemental_data_key} #{expected_supplemental_value} expected but was not found"
        logger.call(err)
      else
        expected_supplemental_value.each_pair do |code,value|
          if code != "UNK" && value != reported_supplemantal_value[code]
            err = "expected supplemental data for #{population_key} #{supplemental_data_key} #{code} value [#{value}] does not match reported supplemental data value [#{ reported_supplemantal_value[code]}]"
            logger.call(err)
          end
        end
        reported_supplemantal_value.each_pair do |code,value|
          if expected_supplemental_value[code].nil?
            err = "unexpected supplemental data for #{population_key} #{supplemental_data_key} #{code}"
            logger.call(err)
          end
        end
      end
    end

  end
end
