class Highlighting < Mustache
  class ClauseObject
    attr_accessor :description, :colored, :is_true, :statement_name, :local_id

    def initialize(description, colored, is_true, statement_name, local_id)
      self.description = description
      self.colored = colored
      self.is_true = is_true
      self.statement_name = statement_name
      self.local_id = local_id
    end
  end

  class Result
    attr_accessor :local_id, :statement_name, :library, :is_true

    def initialize(local_id, statement_name, library, is_true = 'NA')
      self.local_id = local_id
      self.statement_name = statement_name
      self.library = library
      self.is_true = is_true
    end
  end

  self.template_path = __dir__

  def initialize(measure, measure_result)
    @statements = {}
    @clause_list = []
    @measure = measure
    @measure_result = measure_result

    @measure_result_list = []
    if measure._id == measure_result.measure_id
      parse_results(measure_result)
      measure.cql_libraries.each do |cql_library|
        parse_elm(cql_library.elm)
      end
    end
    @clause_list.each do |clause|
      @statements[clause.statement_name] = { statement_name: clause.statement_name, clauses: [] } if @statements[clause.statement_name].nil?
      @statements[clause.statement_name].clauses << clause
    end
    colate_population_statements
  end

  def colate_population_statements
    @population_statements = []
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
    relevant_statements = @statements.sort.to_h.values.select { |s| s[:clauses].first.colored == true }
    JSON.parse(relevant_statements.to_json)
  end

  def statment_result
    statement_result = @measure_result.statement_results.select { |mr| mr.statement_name == self['clauses'].first['statement_name'] }.first
    statement_result.final == 'TRUE' ? 'clause-true' : 'clause-false'
  end

  def population_statements
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
    measure_result.clause_results.each do |clause|
      if clause.respond_to?(:localId) && clause.respond_to?(:final)
        @measure_result_list << Result.new(clause.localId, clause.statement_name, clause.library_name, clause.final)
      end
    end
  end

  def parse_statement(array, library_name)
    array.each do |statement|
      # check for Annotation and local_id. if none move to next
      # if statement.include?(:annotation) && statement.include?(:local_id) && statement.include?(:library_name)
      next unless statement.include?(:annotation) && statement.include?(:localId)

      statement.annotation.each do |annotation|
        statement_name = statement.name
        results = @measure_result_list.select { |x| x.statement_name.eql?(statement_name) && x.library.eql?(library_name) }
        parse_tree(annotation.s, results)
      end
    end
  end

  def parse_tree(array, results, r = nil)
    if array.include?(:s)
      array.s.each do |sarray|
        r_val = sarray['r'] || array['r']
        r_val ||= r
        parse_tree(sarray, results, r_val)
      end
    elsif array.include?(:value)
      array['value'].each do |text|
        result = results.find { |res| res.local_id == r }
        next if result.nil?

        @clause_list << if result.is_true == 'NA'
                          ClauseObject.new(text, false, false, result.statement_name, result.local_id)
                        else
                          ClauseObject.new(text, true, result.is_true == 'TRUE', result.statement_name, result.local_id)
                        end
      end
    end
  end
end
