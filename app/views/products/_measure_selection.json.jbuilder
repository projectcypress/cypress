json.measures @measures.map(&:hqmf_id)

# Guarantee that measure tabs will still show up in the result even if it is empty below
json.measure_tabs({})
json.set! 'measure_tabs' do
  @measures_categories.each do |category, measures|
    json.set! get_div_name(category), formatted_type_counts(category, measures)
  end
end
