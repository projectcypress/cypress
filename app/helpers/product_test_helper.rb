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
    %{<td class="marker #{'p' if !value.nil? && value >= 1}"></td>}.html_safe
  end


  def expected_reported( expected, reported, style={})

    reported_class = result_class(reported,expected)
    extra = style.collect{|k,v| "#{k}='#{v}'"}.join(" ")
   %{<td #{extra}>
       <span class="#{reported_class}">#{reported || (expected ? '-' : '')}</span> / <span>#{expected}
       </span>
     </td>}.html_safe
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