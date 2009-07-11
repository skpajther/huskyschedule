class UpdateCourseAddRatingAndRatingNumber < ActiveRecord::Migration
  def self.up
    add_column :courses, :rating, :integer
    add_column :courses, :total_ratings, :integer
  end

  def self.down
    remove_column :courses, :rating
    remove_column :courses, :total_ratings
  end
end
