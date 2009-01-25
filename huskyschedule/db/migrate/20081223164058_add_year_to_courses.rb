class AddYearToCourses < ActiveRecord::Migration
  def self.up
    add_column(:courses, :year, :integer)
  end

  def self.down
    remove_column(:courses, :year)
  end
end
