module MeasuresHelper
  def measure_result_class(expected, reported, component)
    if (expected[component].class==String || reported[component].class==String)
      'na'
    elsif (expected[component]!=reported[component])
      'fail'
    else
      ''
    end
  end
end
