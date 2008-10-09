class UpdateCourseAddRatingAndRatingNumber < ActiveRecord::Migration
  def self.up
    add_column :courses, :rating, :integer
    add_column :courses, :total_reviews, :integer
  end

  def self.down
    remove_column :courses, :rating
    remove_column :courses, :total_reviews
  end
end
