# The Interval model is an extension of app/models/qdm/basetypes/interval.rb as defined by CQM-Models.
module QDM
  class Interval
    def shift_dates(date_diff)
      formatstr = '%FT%T%:z'
      low_date = DateTime.parse(low).utc
      high_date = DateTime.parse(high).utc
      low = low.nil? ? nil : (low_date + date_diff).strftime(formatstr)
      high = high.nil? ? nil : (high_date + date_diff).strftime(formatstr)
    end
  end
end
