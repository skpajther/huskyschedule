class CreateTeacherRatings < ActiveRecord::Migration
  def self.up
    create_table :teacher_ratings do |t|
      t.integer :teacher_id
      t.integer :course_taught_id
      t.integer :rating
      t.text :pros
      t.text :cons
      t.text :other_thoughts
      t.string :name
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :teacher_ratings
  end
end
