module ProductTestHelper
  def result_class(expected, reported)
    if expected.class == String
      return 'na'
    elsif expected != reported
      return 'f'
    else
      return ''
    end
  end
end