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
end