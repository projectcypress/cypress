module Cypress
  class  PdfGenerator
    def self.generate_for(test_execution, path)
      type =  test_execution.product_test.class.to_s.underscore

      pdf = send(type, test_execution)
      pdf.render_file file_name(test_execution, path)
    end

    private

    def self.file_name(test_execution, path)
      name = test_execution.product_test.name
      pretty_date = test_execution.execution_date.strftime("%m-%d-%Y")
      
      File.join(path, "#{name}-#{pretty_date}.pdf")
    end

    def self.summary_section(pdf, test_execution)

    end

    def self.calculated_product_test(test_execution)
      pdf = Prawn::Document.new
      
      pdf.text "Hey, check out Mr. EP PDF!"

      pdf
    end

    def self.inpatient_product_test(test_execution)
      pdf = Prawn::Document.new

      pdf.text "Hey, check out Mr. EH PDF!"

      pdf
    end

    def self.qrda_product_test(test_execution)
      pdf = Prawn::Document.new

      pdf.text "Hey, check out Mr. QRDA PDF!"

      pdf
    end
  end
end