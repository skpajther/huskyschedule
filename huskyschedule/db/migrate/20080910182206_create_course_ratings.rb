class CreateCourseRatings < ActiveRecord::Migration
  def self.up
    create_table :course_ratings do |t|
      t.integer :quarter_taken
      t.integer :teacher_id
      t.integer :rating
      t.text :pros
      t.text :cons
      t.text :other_thoughts
      t.text :rating_name
      t.integer :user_id
      t.string :class_name

      t.timestamps
    end
  end

  def self.down
    drop_table :course_ratings
  end
end
