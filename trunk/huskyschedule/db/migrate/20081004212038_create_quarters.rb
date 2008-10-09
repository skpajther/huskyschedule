class CreateQuarters < ActiveRecord::Migration
  def self.up
    create_table :quarters do |t|
      t.integer :quarter
      t.integer :year

      t.timestamps
    end
  end

  def self.down
    drop_table :quarters
  end
end
