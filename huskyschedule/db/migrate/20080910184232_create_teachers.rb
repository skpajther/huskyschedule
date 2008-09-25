class CreateTeachers < ActiveRecord::Migration
  def self.up
    create_table :teachers do |t|
      t.string :name
      t.string :current_photo_location

      t.timestamps
    end
  end

  def self.down
    drop_table :teachers
  end
end
