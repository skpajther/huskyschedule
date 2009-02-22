class Streetview < ActiveRecord::Migration
  def self.up
    add_column(:buildings, :sv_yaw, :float)
    add_column(:buildings, :sv_pitch, :float)
    add_column(:buildings, :sv_zoom, :integer)
    add_column(:buildings, :sv_lat, :float)
    add_column(:buildings, :sv_lng, :float)
  end

  def self.down
    remove_column(:buildings, :sv_yaw)
    remove_column(:buildings, :sv_pitch)
    remove_column(:buildings, :sv_zoom)
    remove_column(:buildings, :sv_lat)
    remove_column(:buildings, :sv_lng)
  end
end
