class AddProductArchiveToChecklistTest < Mongoid::Migration
  def self.up
    say_with_time 'Adding Product Archive to Checklist Test' do
      ChecklistTest.each(&:archive_patients)
    end
  end

  def self.down; end
end
