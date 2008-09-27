class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.integer :sln
      t.integer :teacher_id
      t.string :title
      t.integer :number
      t.integer :status
      t.integer :students_enrolled
      t.integer :enrollment_space
      t.integer :credits
      t.boolean :restrictions
      t.string :deptabriev
      t.text :notes
      t.text :credit_type
      t.string :section
      t.text :times
      t.text :description
      t.boolean :crnc
      t.integer :parent_id
      t.integer :quarter
      t.integer :building_id
      t.string :room

      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
