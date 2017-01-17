class RenameManualToChecklist < Mongoid::Migration
  def self.up
    db = Mongoid::Clients.default
    db[:tasks].find('_type' => /Manual/).each do |mt|
      db[:tasks].update_one({ '_id' => mt['_id'] }, '$set' => { '_type' => mt['_type'].sub(/Manual/, 'Checklist') })
    end
  end

  def self.down
    db = Mongoid::Clients.default
    db[:tasks].find('_type' => /Checklist/).each do |mt|
      db[:tasks].update_one({ '_id' => mt['_id'] }, '$set' => { '_type' => mt['_type'].sub(/Checklist/, 'Manual') })
    end
  end
end
