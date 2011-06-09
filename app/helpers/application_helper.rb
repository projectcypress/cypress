module ApplicationHelper
  def display_time(seconds_since_epoch)
    Time.at(seconds_since_epoch).strftime('%m/%d/%Y')
  end

  def result_class(expected, reported, component)
    if (expected[component].class==String || reported[component].class==String)
      'na'
    elsif (expected[component]!=reported[component])
      'fail'
    else
      ''
    end
  end
end
