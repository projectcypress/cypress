class Highlighting < Mustache
  # This is a set of helper methods to allow for measure highlighting.  Currently it
  # can display the results of the data and hightlight the portions as true, or false
  # based on individual result.
  class ClauseObject
    # A ClauseObject will hold a specific clause with the information to which statement
    # it belongs to and the individual result for highlighting purposes.
    attr_accessor :description, :colored, :is_true, :statement_name, :local_id

    def initialize(description, colored, is_true, statement_name, local_id)
      self.description = description        # Text description of the clause object
      self.colored = colored                # Determins if clause should be highlighted
      self.is_true = is_true                # Determines color of highlighting based on T/F
      self.statement_name = statement_name  # Statement_name for locating which statment this belongs to
      self.local_id = local_id              # Local Id to be used wiht statment_name for clause identification
    end
  end

  class Result
    # A result holds a specific result for purposes of identifying the highlighting
    # of specific clauses.
    attr_accessor :local_id, :statement_name, :library, :is_true

    def initialize(local_id, statement_name, library, is_true = 'NA')
      self.local_id = local_id              # ID of the reuslt to be used to find which clause it belongs to
      self.statement_name = statement_name  # Statement_name for locating which statment this belongs to
      self.library = library                # Library of the result to be used with local Id to find specific clause
      self.is_true = is_true                # Determins is this specific result is treu/false or NA for highlighting
    end
  end

  self.template_path = __dir__

  def initialize(measure, measure_result)
    @statements = {}                  # Hash used to store causes based on statement_name
    @clause_list = []                 # List of specific Clauses
    @measure = measure                # specific measure sent in
    @measure_result = measure_result  # result of the measure sent in
    @measure_result_list = []         # Used to contain the full list of results.

    if measure._id == measure_result.measure_id
      # Validate that result is for measure sent in.
      parse_results(measure_result)
      measure.cql_libraries.each do |cql_library|
        parse_elm(cql_library.elm)
      end
    end

    @clause_list.each do |clause|
      # For each clause, find the statment it belongs to, if none create a new statement for it.
      @statements[clause.statement_name] = { statement_name: clause.statement_name, clauses: [] } if @statements[clause.statement_name].nil?
      @statements[clause.statement_name].clauses << clause
    end

    colate_population_statements
  end

  def colate_population_statements
    # Loop through and sort the statements into a more desirable order.
    @population_statements = [] # used to all population statements.
    population_titles = ['Initial Population', 'Denominator', 'Numerator', 'Measure Population']
    population_titles.each do |pop_title|
      statements_for_population = @statements.select { |k| k.start_with?(pop_title) }.values
      relevant_populations = statements_for_population.select { |s| s[:clauses].first.colored == true }
      @population_statements.concat relevant_populations
    end
    @population_statements.map(&:statement_name).each do |statement_name|
      @statements.delete(statement_name)
    end
  end

  def statements
    # parse all relevant statements to JSON
    relevant_statements = @statements.sort.to_h.values.select { |s| s[:clauses].first.colored == true }
    JSON.parse(relevant_statements.to_json)
  end

  def statment_result
    # this is a helper function from mustache t set the CSS use of the clause.
    statement_result = @measure_result.statement_results.select { |mr| mr.statement_name == self['clauses'].first['statement_name'] }.first
    statement_result.final == 'TRUE' ? 'clause-true' : 'clause-false'
  end

  def population_statements
    # Loop through and sort the statements into a more desirable order then parse into JSON
    population_titles = ['Initial Population', 'Denominator', 'Denominator Exclusions', 'Numerator',
                         'Denominator Exceptions', 'Measure Population', 'Measure Population Exclusions']
    @population_statements.each do |ps|
      population_titles.each_with_index do |pt, index|
        ps[:rank] = index if ps.statement_name.include?(pt)
      end
    end
    @population_statements.sort_by!(&:rank)
    JSON.parse(@population_statements.compact.to_json)
  end

  def parse_elm(elm)
    parse_statement(elm.library.statements.def, elm.library.identifier.id)
  end

  def parse_results(measure_result)
    # Parse all results from the measure_result and store them in the measure_result_list
    measure_result.clause_results.each do |clause|
      if clause.respond_to?(:localId) && clause.respond_to?(:final)
        @measure_result_list << Result.new(clause.localId, clause.statement_name, clause.library_name, clause.final)
      end
    end
  end

  def parse_statement(array, library_name)
    array.each do |statement|
      # check for Annotation and local_id. if none move to next
      next unless statement.include?(:annotation) && statement.include?(:localId)

      statement.annotation.each do |annotation|
        # When there is an annotation, find the result that matches and follow down the parse tree
        statement_name = statement.name
        results = @measure_result_list.select { |x| x.statement_name.eql?(statement_name) && x.library.eql?(library_name) }
        parse_tree(annotation.s, results)
      end
    end
  end

  def parse_tree(array, results, r = nil)
    # Follow down each subtree until reaching the clause text then add it with the result to the clause_list
    if array.include?(:s)
      array.s.each do |sarray|

        # If sub array contains its own ID, use that one for the clause
        r_val = sarray['r'] || array['r']
        r_val ||= r
        parse_tree(sarray, results, r_val)
      end
    elsif array.include?(:value)
      array['value'].each do |text|
        result = results.find { |res| res.local_id == r }
        next if result.nil?
        
        # when reaching the bottom of the tree, find result for this clause and add it to the clause_list.
        @clause_list << if result.is_true == 'NA'
                          ClauseObject.new(text, false, false, result.statement_name, result.local_id)
                        else
                          ClauseObject.new(text, true, result.is_true == 'TRUE', result.statement_name, result.local_id)
                        end
      end
    end
  end
end
