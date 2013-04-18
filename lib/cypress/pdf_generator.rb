module Cypress
  class  PdfGenerator
    def initialize(test_execution)
      @test_execution = test_execution
      @pdf = Prawn::Document.new
    end

    def generate(path)
      type = @test_execution.product_test.class.to_s.underscore

      send(type)
      @pdf.render_file file_name(path)
    end

    def file_name(path)
      name = @test_execution.product_test.name
      pretty_date = @test_execution.execution_date.strftime("%m-%d-%Y")
      
      File.join(path, "#{name}-#{pretty_date}.pdf")
    end

    def calculated_product_test
      set_default_style

      summary_section
      measure_errors_section
      qrda_errors_section
      qrda_warnings_section
      quality_measures_section
      vendor_xml_section
    end

    def inpatient_product_test
      set_default_style

      summary_section
      measure_errors_section
      qrda_errors_section
      qrda_warnings_section
      quality_measures_section
      vendor_xml_section
    end

    def qrda_product_test
      set_default_style

      summary_section
      non_qrda_errors_section
      qrda_errors_section
      qrda_warnings_section
      vendor_xml_section
    end

    def static_cv_product_test
      set_default_style

      summary_section
      measure_errors_section
      qrda_errors_section
      qrda_warnings_section
      quality_cv_measures_section
      vendor_xml_section
    end


    private

    FONT_DEFAULT = "Helvetica"
    FONT_XML = "Menlo"

    SIZE_DEFAULT = 10
    SIZE_HEADER = 13
    
    COLOR_DEFAULT = "333333"
    COLOR_HEADER = "666666"
    COLOR_PASSING = "008000"
    COLOR_WARNING = "FFA500"
    COLOR_FAILING = "FF0000"
    
    WEIGHT_DEFAULT = :normal
    WEIGHT_BOLD = :bold

    def set_style(style)
      @pdf.font style[:font] if style[:font]
      @pdf.font_size style[:size] if style[:size]
      @pdf.font @pdf.font.family, style: style[:weight] if style[:weight]
      @pdf.fill_color style[:color] if style[:color]
    end

    def set_default_style
      set_style({
        font: FONT_DEFAULT,
        size: SIZE_DEFAULT,
        color: COLOR_DEFAULT,
        weight: WEIGHT_DEFAULT
      })
    end

    def new_section_margin
      @pdf.move_down @pdf.font_size * 2
    end

    def summary_section
      @pdf.image File.join(Rails.root, "app", "assets", "images", "cypress_logo.png"), :height => 30, :width => 115

      new_section_margin
      @pdf.text "Test Date: #{@test_execution.created_at}"
      @pdf.text "Inspection ID: #{@test_execution.product_test.product.vendor.name}"
      @pdf.text "Errors: #{@test_execution.count_errors}"
      @pdf.text "Warnings: #{@test_execution.count_warnings}"
    end

    def measure_errors_section
      errors = @test_execution.execution_errors.by_validation_type(:result_validation).by_type(:error)
      unless errors.empty?
        new_section_margin
        @pdf.text "Errors"
      end

      errors.each_with_index do |error, index|
        @pdf.text "#{index + 1}. #{error.measure_id} #{error.message}"
      end
    end

    def non_qrda_errors_section
      errors = @test_execution.execution_errors.by_type(:error).to_a.reject {|e| e.validation_type == :xml_validation}
      unless errors.empty?
        new_section_margin
        @pdf.text "Errors"
      end
      
      grouped_errors = errors.group_by(&:file_name)
      grouped_errors.each_pair do |fname, err_group|
        @pdf.text fname || ""
        err_group.each_with_index do |error, index|
         @pdf.text "#{index + 1}. #{error.message}"
        end
        @pdf.text  ""
    end
    end

    def qrda_errors_section
      errors = @test_execution.execution_errors.by_validation_type(:xml_validation).by_type(:error)
      unless errors.empty?
        new_section_margin
        @pdf.text "QRDA Errors"
      end
      
      errors.each_with_index do |error, index|
        @pdf.text "#{index + 1}. #{error.message}"
      end
    end

    def qrda_warnings_section
      errors = @test_execution.execution_errors.by_validation_type(:xml_validation).by_type(:warning)
      unless errors.empty?
        new_section_margin
        @pdf.text "QRDA Warnings"
      end
      
      errors.each_with_index do |error, index|
        @pdf.text "#{index + 1}. #{error.message}"
      end
    end

    def quality_measures_section
      new_section_margin
      @pdf.text "PASSING MEASURES"
      if @test_execution.passing_measures.count == 0
        @pdf.text "There are no passing measures for this test."
      else
        results_table(@test_execution.passing_measures)
      end
      
      new_section_margin
      @pdf.text "FAILING MEASURES"
      if @test_execution.failing_measures.count == 0
        @pdf.text "There are no failing measures for this test."
      else
        results_table(@test_execution.failing_measures)
      end
    end

     def quality_cv_measures_section
      new_section_margin
      @pdf.text "PASSING MEASURES"
      if @test_execution.passing_measures.count == 0
        @pdf.text "There are no passing measures for this test."
      else
        cv_results_table(@test_execution.passing_measures)
      end
      
      new_section_margin
      @pdf.text "FAILING MEASURES"
      if @test_execution.failing_measures.count == 0
        @pdf.text "There are no failing measures for this test."
      else
        cv_results_table(@test_execution.failing_measures)
      end
    end

    def results_table(measures)
      table_content = []
      table_content << ["Measures included in this test", "Patients", "Denominator", "Den. Exclusions", "Numerator", "Num. Exclusions", "Exceptions"]
      
      measures.each do |measure|
        row = []

        expected_result = @test_execution.expected_result(measure)
        reported_result = @test_execution.reported_result(measure)

        measure = "#{measure.nqf_id} - #{measure.name} "
        measure.concat(" - #{measure.subtitle}") if measure["sub_id"]
        patients = "#{reported_result[QME::QualityReport::POPULATION]}/#{expected_result[QME::QualityReport::POPULATION]}"

        row << measure
        row << patients

        [QME::QualityReport::DENOMINATOR , QME::QualityReport::EXCLUSIONS, QME::QualityReport::NUMERATOR , "NUMEX" ,QME::QualityReport::EXCEPTIONS].each do |code|
          expected = expected_result[code]
          reported = reported_result[code]

          unless expected_result["population_ids"][code] 
            expected = nil
            reported = nil
          end
          row << "#{reported || "-"} / #{expected}"
        end

        table_content << row
      end

      set_style({size: 8})
      @pdf.table(table_content, column_widths: [175, 60, 60, 60, 60, 60, 60])
      set_default_style
    end


    def cv_results_table(measures)
      table_content = []
      table_content << ["Measures included in this test", "Patients/Episodes", "Measure Population", "Observation Value"]
      
      measures.each do |measure|
        row = []

        expected_result = @test_execution.expected_result(measure)
        reported_result = @test_execution.reported_result(measure)

        measure = "#{measure.nqf_id} - #{measure.name} "
        measure.concat(" - #{measure.subtitle}") if measure["sub_id"]
        patients = "#{reported_result[QME::QualityReport::POPULATION]}/#{expected_result[QME::QualityReport::POPULATION]}"

        row << measure
        row << patients

        [QME::QualityReport::MSRPOPL , QME::QualityReport::OBSERVATION].each do |code|
          expected = expected_result[code]
          reported = reported_result[code]

          unless expected_result["population_ids"][code] 
            expected = nil
            reported = nil
          end
          row << "#{reported || "-"} / #{expected}"
        end

        table_content << row
      end

      set_style({size: 8})
      @pdf.table(table_content, column_widths: [175, 60, 60, 60, 60, 60, 60])
      set_default_style
    end


    def vendor_xml_section
      # TODO - This section is repetitive unless we can link the earlier error and warning sections to the relevant entries here.
      #new_section_margin
      #@pdf.text "Vendor Generated XML"

      #render :partial=>"test_executions/node.html" , :locals=>{:doc=>doc, :error_map=>error_map, :error_attributes=>error_attributes}
    end
  end
end