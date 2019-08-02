class Highlighting < Mustache

    class HighlightObject
        attr_accessor :description, :colored, :isTrue, :userId, :isClauseStart, :isClauseEnd

        def initialize(description, colored, isTrue, userId)
            self.description = description
            self.colored = colored
            self.isTrue = isTrue
            self.userId = userId
        end
    end

    class Result
        attr_accessor :userId, :library, :isTrue

        def initialize(userId, library, isTrue = "NA")
            self.userId = userId
            self.library = library
            self.isTrue = isTrue
        end
    end
    
    self.template_path = __dir__

    def initialize(measures, measureResults)
        @highlightObject = []
        @neasureResultList = []

        measureResults.each_with_index do |result, index|
            @measureResultList = []
            measure = measures.find { |x| x._id == result.measure_id }
            if measure._id == result.measure_id
                ParseResults(result)
                measure.cql_libraries.each do |cql_library|
                    ParseElm(cql_library.elm)
                end
            end
        end
        @highlight = highlight
    end

    def highlight
        @highlightObject.each_with_index do |highlight_object, index|
            highlight_object.isClauseStart = (highlight_object.userId != @highlightObject[index - 1].userId)
            highlight_object.isClauseEnd = (index == @highlightObject.size - 1) || highlight_object.userId != @highlightObject[index + 1].userId
        end
        JSON.parse(@highlightObject.to_json)
    end

    def ParseElm(elm)
        ParseStatement(elm.library.statements.def, elm.library.identifier.id)
    end

    def ParseResults(measureResult)
        measureResult.clause_results.each do |clause|
            if clause.respond_to?(:localId) && clause.respond_to?(:final)
                @measureResultList << Result.new(clause.localId, clause.library_name, clause.final)
            end
        end 
    end

    def ParseStatement(array, libraryName)
        array.each_with_index do |statement, index|
            # check for Annotation and localId. if none move to next
#             if statement.include?(:annotation) && statement.include?(:localId) && statement.include?(:library_name)
            print "Next Statement " + index.to_s + "\n"
             if statement.include?(:annotation) && statement.include?(:localId)
                statement.annotation.each do |annotation|
                    localId = statement.localId
                    result = @measureResultList.find { |x| x.userId.eql?(localId) && x.library.eql?(libraryName) }
                    ParseTree(annotation.s, result)
                end
             end
        end
    end

    def ParseTree(array, result)
        if array.include?(:s)
            array.s.each do |sarray|
                ParseTree(sarray, result)
            end
        else array.include?(:value)
            array['value'].each do |text|
                unless result.nil?
                    if result.isTrue.eql?("NA")
                        @highlightObject << HighlightObject.new(text, false, false, result.userId)
                    else
                        @highlightObject << HighlightObject.new(text, true, ActiveModel::Type::Boolean.new.cast(result.isTrue), result.userId)
                        print result.isTrue + "\n" 
                    end
                end
            end
        end
    end
end
