class FixBuildingsAgain < ActiveRecord::Migration
  def self.up
    change_column :buildings, :lat, :float, :limit => 53
    change_column :buildings, :lng, :float, :limit => 53
    change_column :buildings, :uw_lat, :float, :limit => 53
    change_column :buildings, :uw_lng, :float, :limit => 53
  end

  def self.down
    change_column :buildings, :lat, :float
    change_column :buildings, :lng, :float
    change_column :buildings, :uw_lat, :float
    change_column :buildings, :uw_lng, :float
  end
end
