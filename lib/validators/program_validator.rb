# frozen_string_literal: true

module Validators
  class ProgramValidator < QrdaFileValidator
    include Validators::Validator

    def initialize(programs)
      @programs = programs.map(&:upcase)
    end

    def validate(file, options = {})
      @document = get_document(file)
      # xpath for informationRecipient, which is where CMS wants the code for the program
      prog = @document.at_xpath('//cda:informationRecipient/cda:intendedRecipient/cda:id/@extension')
      if !prog
        msg = "Expected to find program(s) '#{@programs.join(', ')}' but no program code was found."
        add_error(msg, file_name: options[:file_name])
      elsif !@programs.include?(prog.value)
        msg = "CMS Program code '#{prog.value}' does not match the expected code for program(s) #{@programs.join(', ')}."
        add_error(msg, file_name: options[:file_name])
      end
    end
  end
end
