# frozen_string_literal: true

module Validators
  class ProgramValidator < QrdaFileValidator
    include Validators::Validator

    def initialize(program)
      @program = program.upcase
    end

    def validate(file, options = {})
      @document = get_document(file)
      # xpath for informationRecipient, which is where CMS wants the code for the program
      prog = @document.at_xpath('//cda:informationRecipient/cda:intendedRecipient/cda:id/@extension')
      if !prog
        msg = "Expected to find program '#{@program}' but no program code was found."
        add_error(msg, file_name: options[:file_name])
      elsif prog.value != @program
        msg = "CMS Program code '#{prog.value}' does not match the expected code for program #{@program}."
        add_error(msg, file_name: options[:file_name])
      end
    end
  end
end
