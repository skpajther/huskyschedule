class FixBuildings < ActiveRecord::Migration
  def self.up
    add_column :buildings, :picture, :string
    change_column :buildings, :lat, :float
    change_column :buildings, :lng, :float
    change_column :buildings, :uw_lat, :float
    change_column :buildings, :uw_lng, :float 
  end

  def self.down
    remove_column :buildings, :picture
    change_column :buildings, :lat, :integer
    change_column :buildings, :lng, :integer
    change_column :buildings, :uw_lat, :integer
    change_column :buildings, :uw_lng, :integer
  end
end
