class UpdateBundleDataModel < Mongoid::Migration
  def self.up
  	bundles = Bundle.where({version: "2.0.0"})
  	if bundles.count > 1
      raise "Cannot contiue - Multiple versions of Bundle 2.0.0 are installed.  This migration can only continue if there are 0 or 1 bundles of version 2.0.0 installed"
    elsif bundles.count == 0
    else
    	bundle = bundles.first
    	bundle[:active] = true
    	bundle.save
      bundle_id = bundle.id

      Measure.where({:bundle_id=>nil}).each do |m|
        if m["bundle"]
          m["bundle_id"] = m["bundle"]
          m.remove_attribute("bundle")
          m.save
        end
      end
      puts "Updated Measures"

      Record.where({:test_id=>nil, :bundle_id=>nil}).each do |m|
        if m["bundle"]
          m["bundle_id"] = m["bundle"]
          m.remove_attribute("bundle")
          m.save
        end
      end

      puts "Updated Records"
      Result.where({:test_id=> nil, :bundle_id=>nil}).update_all({"bundle_id" => bundle_id})
      # Result.where({:test_id=> nil, :bundle_id=>nil}).to_a.each do |m|
      #     m["bundle_id"] = bundle_id
      #     m.save
      # end

      puts "Updated Patient cache"
      ProductTest.where({}).update_all({"bundle_id" => bundle_id})

      puts "updated product tests"
      HealthDataStandards::SVS::ValueSet.where({:bundle_id => nil}).update_all({"bundle_id" => bundle_id})

      puts "updated valuesets"
      start_date = 1.year.ago(Time.at(bundle.effective_date)).to_i 
      bundle[:measure_period_start] = start_date
      bundle.save
    end

     puts "Indexing database"
    ::Rails.application.eager_load!

    Mongoid.models.each do |model|
      next if model.index_options.empty?
      unless model.embedded?
        model.create_indexes
      end
    end
    puts "Finished"
  end
  # there is no going back from this 
  def self.down

  end
end