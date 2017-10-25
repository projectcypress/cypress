class RenameManualToChecklist < Mongoid::Migration
  def self.up
    db = Mongoid::Clients.default
    say_with_time 'Renaming Manual to Checklist' do
      db[:tasks].find('_type' => /Manual/).each do |mt|
        db[:tasks].update_one({ '_id' => mt['_id'] }, '$set' => { '_type' => mt['_type'].sub(/Manual/, 'Checklist') })
      end
    end
  end

  def self.down
    db = Mongoid::Clients.default
    say_with_time 'Renaming Checklist to Manual' do
      db[:tasks].find('_type' => /Checklist/).each do |mt|
        db[:tasks].update_one({ '_id' => mt['_id'] }, '$set' => { '_type' => mt['_type'].sub(/Checklist/, 'Manual') })
      end
    end
  end
end
