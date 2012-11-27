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


  def test_type(test)
  	type = {CalculatedProductTest=>"EP", InpatientProductTest=>"EH", QRDAProductTest=>"QRDA"}[test.class]
  	type || "Unkown"
  end

  def group_measures_by_type(measures)
    ret = {:proportional=>[], :continuous=>[]}
    (measures ||[]).each do |mes|
      if mes.population_ids["MSRPOPL"]
        ret[:continuous] << mes
      else
        ret[:proportional] << mes
      end
    end
    ret
  end
end