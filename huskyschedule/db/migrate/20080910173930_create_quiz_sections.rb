class CreateQuizSections < ActiveRecord::Migration
  def self.up
    create_table :quiz_sections do |t|
      t.integer :sln
      t.integer :teacher_id
      t.integer :status
      t.integer :students_enrolled
      t.integer :enrollment_space
      t.boolean :restrictions
      t.text :notes
      t.string :section
      t.text :times
      t.text :description
      t.boolean :crnc
      t.integer :parent_id
      t.integer :building_id
      t.string :room
    
      t.timestamps
    end
  end

  def self.down
    drop_table :quiz_sections
  end
end
