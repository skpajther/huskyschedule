class AddColorsArrayToSchedules < ActiveRecord::Migration
  def self.up
    add_column(:schedules, :colors, :text)
  end

  def self.down
    remove_column(:schedules, :colors)
  end
end
