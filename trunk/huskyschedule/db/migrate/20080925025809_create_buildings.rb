class CreateBuildings < ActiveRecord::Migration
  def self.up
    create_table :buildings do |t|
      t.string :name
      t.decimal :lat
      t.decimal :lng
      t.string :abbrev
      t.decimal :uw_lat
      t.decimal :uw_lng
    
      t.timestamps
    end
  end

  def self.down
    drop_table :buildings
  end
end
