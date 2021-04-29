# frozen_string_literal: true

module Cypress
  class DataCriteriaAttributeBuilder
    def build_data_criteria_for_measure(measure)
      @measure = measure
      @vs_hash = {}
      @cql_data_criteria = []
      @unionlist = []
      @root_data_criteria = {}
      @expression_hash = {}
      @alias_hash = {}
      @unions = {}
      @dependencies = {}
      @alias_expression_hash = {}
      begin
        measure.cql_libraries.each do |cql_library|
          extract_dependencies(cql_library)
          cql_library['elm'].each_value do |library|
            extract_elements_from_library(library)
            extract_code_and_valueset_names(library['valueSets']) if library['valueSets']
            extract_code_and_valueset_names(library['codes']) if library['codes']
          end
        end
        find_union_values
        @unions.each do |union_key, union_value|
          @root_data_criteria[union_key] = union_value
        end
        # Go through each statement for each library to find elements that have properties
        measure.cql_libraries.each do |cql_library|
          cql_library['elm'].each_value do |library|
            library_id = library['identifier']['id']
            library['statements']['def'].each do |current_hash|
              next unless @dependencies[library_id].include? current_hash['name']

              find_sub_elements_with_properties(library_id, current_hash['localId'], current_hash)
            end
          end
        end
        update_measure_data_criteria
      rescue StandardError
        # Do nothing
      end
    end

    def extract_dependencies(library)
      @dependencies[library['library_name']] = []
      library['statement_dependencies'].each do |statement|
        @dependencies[library['library_name']] << statement['statement_name'] unless @dependencies[library['library_name']].include? statement['statement_name']
      end
    end

    # def unions
    #   @unions
    # end

    # def root_data_criteria
    #   @root_data_criteria
    # end

    def update_measure_data_criteria
      @cql_data_criteria.each do |cdc|
        data_criteria_name = cdc['data_criteria']
        valuesets = find_root_vs([data_criteria_name])
        @measure.source_data_criteria.each do |sdc|
          next unless (valuesets.include? sdc.codeListId) || ((sdc.codeListId[0, 3] == 'drc') && (valuesets.include? ValueSet.where(oid: sdc.codeListId).first&.concepts&.first&.code))
          next if sdc.dataElementAttributes && (sdc.dataElementAttributes.any? { |h| h.attribute_name == cdc['attribute'] && h.attribute_valueset == cdc['attribute_vs'] })
          # only add attribute if it is approprate for the QDM type
          next unless sdc.respond_to? cdc['attribute']

          dea = { attribute_name: cdc['attribute'], attribute_valueset: cdc['attribute_vs'] }
          sdc.dataElementAttributes << dea
          sdc.save
        end
      end
    end

    # expression_id = statement's localId
    # library_id => id for library where the statment can be found
    # current_hash = hash of the current element
    # parent_hash = hash of the parent element
    # parent_hash_name = name of the element
    # grand_parent_hash = has of the grandparent element
    def find_sub_elements_with_properties(library_id, expression_id, current_hash, parent_hash = nil, parent_hash_name = nil, grand_parent_hash = nil)
      # iterate through every element in the hash
      current_hash.each do |name, values|
        # if the sub element is a Property (that is a child of a code element)
        next if name == 'annotation'

        if name == 'type' && values == 'Property' && parent_hash_name == 'code' && current_hash['path'] != 'code'
          # scope is the associated data criteria (or alias)
          scope = find_data_criteria_for_property(library_id, expression_id, current_hash)
          @cql_data_criteria << { 'attribute' => current_hash['path'],
                                  'data_criteria' => scope,
                                  'attribute_vs' => @vs_hash[parent_hash['valueset']['name']] }
        elsif name == 'type' &&  values == 'Property' && (%w[expression where].include? parent_hash_name) && current_hash['path'] != 'code'
          scope = find_data_criteria_for_property(library_id, expression_id, current_hash)
          next if scope.nil?

          if grand_parent_hash['where'] && grand_parent_hash['where']['valueset']
            @cql_data_criteria << { 'attribute' => current_hash['path'],
                                    'data_criteria' => scope,
                                    'attribute_vs' => @vs_hash[grand_parent_hash['where']['valueset']['name']] }
          elsif grand_parent_hash['where'] && (%w[And Or].include? grand_parent_hash['where']['type'])
            find_nested_and_or_sub_elements(grand_parent_hash['where'], current_hash, scope)
          end
        elsif name == 'type' &&  values == 'Property' && grand_parent_hash['type'] == 'Equivalent'
          scope = find_data_criteria_for_property(library_id, expression_id, current_hash)
          next if scope.nil?

          @cql_data_criteria << { 'attribute' => current_hash['path'],
                                  'data_criteria' => scope,
                                  'attribute_vs' => @vs_hash[grand_parent_hash['operand'][1]['name']] }
        elsif name == 'type' &&  values == 'Property' && grand_parent_hash['type'] == 'InValueSet'
          scope = find_data_criteria_for_property(library_id, expression_id, current_hash)
          next if scope.nil?

          @cql_data_criteria << { 'attribute' => current_hash['path'],
                                  'data_criteria' => scope,
                                  'attribute_vs' => @vs_hash[grand_parent_hash['valueset']['name']] }
        elsif name == 'type' &&  values == 'Property' && parent_hash['type'] == 'Equivalent'
          scope = find_data_criteria_for_property(library_id, expression_id, current_hash)
          next if scope.nil?

          @cql_data_criteria << { 'attribute' => current_hash['path'],
                                  'data_criteria' => scope,
                                  'attribute_vs' => @vs_hash[parent_hash['operand'][1]['name']] }
        elsif name == 'type' &&  values == 'Property' && parent_hash_name != 'code' && current_hash['path'] != 'code'
          scope = find_data_criteria_for_property(library_id, expression_id, current_hash)
          next if scope.nil?

          @cql_data_criteria << { 'attribute' => current_hash['path'],
                                  'data_criteria' => scope }
        elsif values.is_a? Hash
          find_sub_elements_with_properties(library_id, expression_id, values, current_hash, name, parent_hash)
        elsif values.is_a? Array
          values.each do |value|
            find_sub_elements_with_properties(library_id, expression_id, value, current_hash, name, parent_hash) if value.is_a? Hash
          end
        end
      end
    end

    # some elements are nested within and-or expressions
    def find_nested_and_or_sub_elements(and_or_hash, current_hash, scope)
      and_or_hash['operand'].each do |inner_and_or_hash|
        if inner_and_or_hash['valueset']
          @cql_data_criteria << { 'attribute' => current_hash['path'],
                                  'data_criteria' => scope,
                                  'attribute_vs' => @vs_hash[inner_and_or_hash['valueset']['name']] }
        elsif %w[And Or].include? inner_and_or_hash['type']
          find_nested_and_or_sub_elements(inner_and_or_hash, current_hash, scope)
        end
      end
    end

    def find_root_vs(criteria_array, root_vs = [])
      criteria_array.each do |criteria_name|
        if @root_data_criteria[criteria_name]
          if @vs_hash.key? criteria_name
            root_vs << @vs_hash[criteria_name]
          else
            return root_vs if criteria_name == @root_data_criteria[criteria_name]

            find_root_vs([@root_data_criteria[criteria_name]].flatten, root_vs)
          end
        elsif @vs_hash[criteria_name]
          root_vs << @vs_hash[criteria_name]
        end
      end
      root_vs
    end

    def find_data_criteria_for_property(library_id, expression_id, current_hash)
      # Return nil if current element has no scope defined (This could be in a child element) look into
      if current_hash['scope'].nil?
        nil
      # if scope of current_hash has an alias associated with it, use that
      elsif !@alias_hash[library_id][expression_id][current_hash['scope']]['name'].nil?
        @alias_hash[library_id][expression_id][current_hash['scope']]['name']
      # if scope of current_hash has an valueset associated with it, use that
      elsif !@alias_hash[library_id][expression_id][current_hash['scope']]['codes'].nil?
        if !@alias_hash[library_id][expression_id][current_hash['scope']]['codes']['name'].nil?
          @alias_hash[library_id][expression_id][current_hash['scope']]['codes']['name']
        else
          @alias_hash[library_id][expression_id][current_hash['scope']]['codes']['operand']['name']
        end
        # if scope of current_hash has an union associated with it, use that
      elsif @alias_hash[library_id][expression_id][current_hash['scope']]['type'] == 'Union'
        current_hash['scope']
      end
    end

    def extract_code_and_valueset_names(code_valueset_collection)
      code_valueset_collection['def'].each do |entry|
        @vs_hash[entry['name']] = entry['id']
      end
    end

    def find_union_values
      @unionlist.each do |union|
        if union['name']
          traverse_union(union, union['name'])
        elsif union['alias']
          traverse_union(union, union['alias'])
        end
      end
    end

    def traverse_union(element, union_alias = nil)
      element.each do |name, values|
        next if name == 'annotation'

        if name == 'type' && values == 'ExpressionRef'
          @unions[union_alias] << element['name']
        elsif name == 'codes'
          @unions[union_alias] << if values['operand']
                                    values['operand']['name']
                                  else
                                    values['name']
                                  end
        elsif name == 'operand'
          if values.is_a? Array
            values.each do |op|
              traverse_union(op, union_alias)
            end
          elsif values.is_a? Hash
            traverse_union(values, union_alias)
          elsif values['type'] == 'ExpressionRef'
            @unions[union_alias] << values['name']
          end
        elsif values.is_a? Hash
          traverse_union(values, union_alias)
        elsif values.is_a? Array
          values.each do |value|
            traverse_union(value, union_alias) if value.is_a? Hash
          end
        end
      end
    end

    def extract_elements_from_library(library)
      library_id = library['identifier']['id']
      @alias_hash[library_id] = {}
      @alias_expression_hash[library_id] = {}
      @expression_hash[library_id] = {}
      library['statements']['def'].each do |statement|
        next unless @dependencies[library_id].include? statement['name']

        parse_statement_for_aliases(statement, library_id)
        parse_statement_for_root_data_types(statement, library_id)
      end
    end

    def parse_statement_for_root_data_types(statement, library_id)
      if statement['expression']['dataType']
        @root_data_criteria[statement['name']] = statement['expression']['codes']['name']
      elsif (%w[First Last].include? statement['expression']['type']) && statement['expression']['source']['type'] == 'ExpressionRef'
        @root_data_criteria[statement['name']] = statement['expression']['source']['name']
      elsif statement['expression']['type'] == 'ExpressionRef'
        @root_data_criteria[statement['name']] = statement['expression']['name']
      elsif statement['expression']['type'] == 'Except'
        @root_data_criteria[statement['name']] = []
        statement['expression']['operand'].each do |op|
          @root_data_criteria[statement['name']] = op['name']
        end
      # If the expression is a Query, search the query for root data criteria (in source and relationships)
      elsif statement['expression']['type'] == 'Query' || ((%w[First Last].include? statement['expression']['type']) && statement['expression']['source']['type'] == 'Query')
        parse_root_data_types_from_query(statement, library_id)
      elsif %w[Union Intersect].include? statement['expression']['type']
        parse_root_data_types_from_union_and_intersetion(statement, library_id)
      end
    end

    def parse_root_data_types_from_query(statement, library_id)
      source_value = []
      qsource = if statement['expression']['type'] == 'Query'
                  statement['expression']['source']
                else
                  statement['expression']['source']['source']
                end
      rsource = if statement['expression']['type'] == 'Query'
                  statement['expression']['relationship']
                else
                  statement['expression']['source']['relationship']
                end
      qsource.each do |query_source|
        parse_query_source(query_source, library_id, statement, source_value)
      end
      rsource.each do |rel_source|
        parse_query_relationship(rel_source, statement)
      end
    end

    def parse_query_relationship(rel_source, statement)
      if rel_source['expression']['dataType']
        if rel_source['expression']['codes']
          name = rel_source['expression']['codes']['name']
          @root_data_criteria[name] = name
        end
      elsif rel_source['expression']['type'] && rel_source['expression']['type'] == 'Union'
        @root_data_criteria[rel_source['alias']] = rel_source['alias']
        @root_data_criteria[statement['name']] = statement['name']
        @unions[rel_source['alias']] = []
        @unions[statement['name']] = []
        @unionlist << rel_source
      end
    end

    def parse_query_source(query_source, library_id, statement, source_value)
      if query_source['alias'] && query_source['expression']['name']
        @alias_expression_hash[library_id][statement['localId']][query_source['alias']] = query_source['expression']['name']
        source_value << query_source['expression']['name']
      elsif query_source['alias'] && query_source['expression']['type'] == 'Union'
        @root_data_criteria[query_source['alias']] = query_source['alias']
        @unions[query_source['alias']] = []
        @unionlist << query_source
      end
      if query_source['expression']['dataType']
        if query_source['expression']['codes']
          if query_source['expression']['codes']['name']
            vs_name = query_source['expression']['codes']['name']
            @root_data_criteria[statement['name']] = vs_name
          elsif query_source['expression']['codes']['operand']
            vs_name = query_source['expression']['codes']['operand']['name']
            @root_data_criteria[statement['name']] = vs_name
          end
        end
      elsif query_source['expression']['type'] && query_source['expression']['type'] == 'Union'
        @root_data_criteria[statement['name']] = statement['name']
        @unions[statement['name']] = []
        @unionlist << statement
      elsif query_source['expression']['type'] && query_source['expression']['type'] == 'Query'
        @root_data_criteria[statement['name']] = query_source['expression']['source'][0]['expression']['codes']['name']
      elsif query_source['expression']['type'] && query_source['expression']['type'] == 'ExpressionRef'
        @root_data_criteria[statement['name']] = query_source['expression']['name']
      elsif query_source['expression']['type'] && query_source['expression']['type'] == 'Last'
        @root_data_criteria[statement['name']] = query_source['expression']['source']['source'][0]['expression']['codes']['name']
      end
      @expression_hash[library_id][statement['name']] = source_value.uniq
    end

    def parse_root_data_types_from_union_and_intersetion(statement, library_id)
      source_value = []
      statement['expression']['operand'].each do |union_sources|
        if union_sources['source']
          union_sources['source'].each do |union_source|
            if union_source['alias'] && union_source['expression']['name']
              @alias_expression_hash[library_id][statement['localId']][union_source['alias']] = union_source['expression']['name']
              source_value << union_source['expression']['name']
            end
          end
        elsif union_sources['codes']
          source_value << union_sources['codes']['name']
        end
      end
      if statement['expression']['type'] == 'Union'
        @unions[statement['name']] = []
        @unionlist << statement
      end
      @expression_hash[library_id][statement['name']] = source_value.uniq
      @root_data_criteria[statement['name']] = source_value.uniq
    end

    def parse_statement_for_aliases(statement, library_id)
      # If statement has a local id create hashes for statement
      return unless statement['localId']

      @alias_hash[library_id][statement['localId']] = {}
      @alias_expression_hash[library_id][statement['localId']] = {}
      # find all aliases in a given statment
      find_alias_values(statement, statement['localId'], library_id)
    end

    def find_alias_values(statement_hash, expression_id, library_id)
      statement_hash.each do |name, values|
        if name == 'alias'
          @alias_hash[library_id][expression_id][values] = statement_hash['expression']
        elsif values.is_a? Hash
          find_alias_values(values, expression_id, library_id)
        elsif values.is_a? Array
          values.each do |value|
            find_alias_values(value, expression_id, library_id) if value.is_a? Hash
          end
        end
      end
    end
  end
end
