namespace :cypress do
  namespace :record_sample do
    desc 'List all of the possible data element/attribute combinations for the loaded measures'
    task :possible_combinations => :environment do
      combo_hash = {}
      Measure.all.each do |measure|
        measure.source_data_criteria.each do |_key, sdc|
          combo_key = sdc['status'].nil? ? sdc['definition'] : "#{sdc['definition']}_#{sdc['status']}"
          combo_hash[combo_key] = [] unless combo_hash.key? combo_key
          next unless sdc['attributes']
          sdc['attributes'].each do |att|
            combo_hash[combo_key] << att['attribute_name'] unless combo_hash[combo_key].include? att['attribute_name']
          end
        end
      end
      combo_hash.sort.each do |key, attributes|
        puts key if attributes.blank?
        attributes.sort.each do |att|
          puts "#{key} - #{att}"
        end
      end
    end
  end
end
