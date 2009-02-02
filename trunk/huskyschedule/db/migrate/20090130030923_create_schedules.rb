class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.integer :user_id
      t.text :courses
      t.integer :quarter
      t.integer :year
      t.string :name
      t.integer :rank
      t.boolean :grab_bag
      
      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
