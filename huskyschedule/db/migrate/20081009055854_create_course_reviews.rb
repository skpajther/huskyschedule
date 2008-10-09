class CreateCourseReviews < ActiveRecord::Migration
  def self.up
    create_table :course_reviews do |t|
      t.integer :quarter_taken
      t.integer :teacher_id
      t.integer :rating
      t.text :pros
      t.text :cons
      t.text :other_thoughts
      t.text :review_name
      t.integer :user_id
      t.string :course_name
      t.integer :year_taken
      
      t.timestamps
    end
  end

  def self.down
    drop_table :course_reviews
  end
end
