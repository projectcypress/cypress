require 'validators/schema_validator'
require 'validators/schematron_validator'
require 'quality-measure-engine'
module Cypress
  class QrdaFile

    CV_METHOD_CODES = ["OBSRV", "COUNT","SUM", "AVERAGE","STDEV.S","VARIANCE.S","STDEV.P","VARIANCE.P","MIN","MAX", "MEDIAN", "MODE"]
    CV_POPULATION_CODE = QME::QualityReport::OBSERVATION

    ISO_SCHEMATRON = 'resources/schematron/iso-schematron-xslt1/iso_svrl_for_xslt1.xsl'
    QRDA_SCHEMA_VALIDATOR = Validators::Schema::Validator.new("CDA Schema validator", APP_CONFIG["validation"]["schema"])

    SUPPLEMENTAL_DATA_MAPPING = {QME::QualityReport::RACE=> "2.16.840.1.113883.10.20.27.3.8",
                                 QME::QualityReport::ETHNICITY => "2.16.840.1.113883.10.20.27.3.7",
                                 QME::QualityReport::SEX => "2.16.840.1.113883.10.20.27.3.6",
                                 QME::QualityReport::PAYER => "2.16.840.1.113883.10.20.27.3.9"}
    MEASURE_VALIDATORS = {}

    def initialize(doc)
      @document = (doc.kind_of? String )? Nokogiri::XML(doc) : doc
      raise ArgumentError, 'Argument was not an XML document' unless @document.root
      @document.root.add_namespace_definition("cda", "urn:hl7-org:v3")
    end

    #takes a document and a list of 1 or more id hashes, e.g.:
    #[{measure_id:"8a4d92b2-36af-5758-0136-ea8c43244986", set_id:"03876d69-085b-415c-ae9d-9924171040c2", ipp:"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", den:"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", num:"9363135E-A816-451F-8022-96CDA7E540DD"}]
    #returns nil if nothing matching is found
    # returns a hash with the values of the populations filled out along with the population_ids added to the result
    def extract_results_by_ids(measure_id,  ids)
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
         and ./cda:reference/cda:externalDocument/cda:id[#{translate("@root")}='#{id.upcase}']] }
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

    def translate(id)
      %{translate(#{id}, "abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ")}
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


    #convert numbers in value nodes to Int / Float as necessary TODO add more types other than 'REAL'
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

  end
end
