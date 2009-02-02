class AddRendezvousToCourse < ActiveRecord::Migration
  def self.up
    add_column(:courses, :rendezvous, :text)
  end

  def self.down
    remove_column(:courses, :rendezvous)
  end
end
