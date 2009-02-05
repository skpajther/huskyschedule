class AddRendezvousColumnsToLabsAndQuizSections < ActiveRecord::Migration
  def self.up
    add_column(:labs, :rendezvous, :text)
    add_column(:quiz_sections, :rendezvous, :text)
  end

  def self.down
    remove_column(:labs, :rendezvous)
    remove_column(:quiz_sections, :rendezvous)
  end
end
