class MeasureTest < ProductTest
  validate :at_most_one_measure?

  def at_most_one_measure?
    errors.add(:measure_ids, 'MeasureTest must have a single measure id') if measure_ids.length != 1
  end
end
