require 'csv'
require 'json'
require 'yaml'

def vs_from_row(row)
  vs_param = {}
  vs_param['ValueSet'] = row['ValueSet']
  vs_param['Weight'] = row['Weight']
  vs_param['IsAttribute'] = row['IsAttribute'] == 'TRUE'
  vs_param
end

previous_measure = nil
measures = {}
valuesets = []
csv_text = File.read('script/export.csv')
csv = CSV.parse(csv_text, headers: true)
csv.each do |row|
  previous_measure = row['Measure'] if previous_measure.nil?
  if row['Measure'] != previous_measure
    measures[previous_measure] = valuesets
    previous_measure = row['Measure']
    valuesets = []
  end
  valuesets << vs_from_row(row)
end
measures[previous_measure] = valuesets
output = File.open('script/cat1checklist.yml', 'w')
output << measures.to_yaml
output.close
