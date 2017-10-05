class AddProductArchiveToChecklistTest < Mongoid::Migration
  def self.up
    ChecklistTest.each do |checklist_test|
      checklist_test.archive_records
    end
  end

  def self.down
  end
end
