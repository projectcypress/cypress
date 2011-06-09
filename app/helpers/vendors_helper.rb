module VendorsHelper
  def result_class(expected, reported, component)
    if (expected[component].class==String || reported[component].class==String)
      'na'
    elsif (expected[component]!=reported[component])
      'f'
    else
      ''
    end
  end
end
