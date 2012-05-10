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
  
  def measure_categories(type = :all_by_measure)
    case type
      when :top_level
        measures = Measure.top_level
        measures.group_by { |t| t['category'] }
      when :all_by_measure
        measures = Measure.all_by_measure
        measures.group_by { |t| t['category'] }
    end
  end
end
