class AddLastSavedToSchedules < ActiveRecord::Migration
  def self.up
    add_column(:schedules, :last_saved, :datetime)
  end

  def self.down
    remove_column(:schedules, :last_saved)
  end
end
