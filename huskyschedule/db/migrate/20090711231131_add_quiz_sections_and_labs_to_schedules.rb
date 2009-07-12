class AddQuizSectionsAndLabsToSchedules < ActiveRecord::Migration
  def self.up
    add_column(:schedules, :quiz_sections, :text)
    add_column(:schedules, :labs, :text)
  end

  def self.down
    remove_column(:schedules, :quiz_sections)
    remove_column(:schedules, :labs)
  end
end
