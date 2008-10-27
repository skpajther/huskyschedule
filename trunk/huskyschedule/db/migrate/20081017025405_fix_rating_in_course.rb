class FixRatingInCourse < ActiveRecord::Migration
  def self.up
    change_column :courses, :rating, :float, :limit => 53
  end

  def self.down
    change_column(:courses, :rating, :integer)
  end
end
