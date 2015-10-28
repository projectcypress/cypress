module ProductTestHelper
  def result_class(expected, reported)
    if expected.class == String || expected.nil?
      return 'na'
    elsif expected != reported
      return 'fail'
    else
      return 'pass'
    end
  end

  def population_marker(value)
    content_tag(:td, "", class: "marker #{'p' if !value.nil? && value >= 1}")
  end


  def expected_reported( expected, reported, style={})
    reported_class = result_class(reported,expected)
    extra = style.values.join('; ')
    content_tag(:td, style: extra) do
      concat content_tag(:span, "#{reported || (expected ? '-' : '')}", class:  "#{reported_class}")
      concat ' / '
      concat content_tag(:span, "#{expected}")
    end
  end

  def file_upload_type(test)
    test.is_a?(QRDAProductTest) ? "application/zip" : "application/xml"
  end

  def test_type(test)
    type = {CalculatedProductTest=>"EP", InpatientProductTest=>"EH", QRDAProductTest=>"QRDA"}[test.class]
    type || "Unkown"
  end

  def group_measures_by_type(measures)
    ret = {:proportional=>[], :continuous=>[]}
    (measures ||[]).each do |mes|
      if mes.population_ids[QME::QualityReport::MSRPOPL]
        ret[:continuous] << mes
      else
        ret[:proportional] << mes
      end
    end
    ret
  end
end
