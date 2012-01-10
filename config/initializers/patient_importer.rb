require 'patient_import_job'

measure_ids = MONGO_DB.collection('measures').find({}, {:fields => {:id => 1}}).map {|r| r['id']}.uniq

measure_ids.each do |id|
  QME::Importer::MeasurePropertiesGenerator.instance.add_measure(id, QME::Importer::GenericImporter.new(MONGO_DB.collection('measures').find_one({:id => id})))
end