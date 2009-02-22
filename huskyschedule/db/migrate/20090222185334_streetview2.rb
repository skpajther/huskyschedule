class Streetview2 < ActiveRecord::Migration
  def self.up
      add_column(:buildings, :sv_yaw, :double)
      add_column(:buildings, :sv_pitch, :double)
      add_column(:buildings, :sv_zoom, :integer)
      add_column(:buildings, :sv_lat, :double)
      add_column(:buildings, :sv_lng, :double)
    end
  
    def self.down
      remove_column(:buildings, :sv_yaw)
      remove_column(:buildings, :sv_pitch)
      remove_column(:buildings, :sv_zoom)
      remove_column(:buildings, :sv_lat)
      remove_column(:buildings, :sv_lng)
    end
end
