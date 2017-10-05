class AddProductArchiveToChecklistTest < Mongoid::Migration
  def self.up
    ChecklistTest.each(&:archive_records)
  end

  def self.down
  end
end
