class FixTeachers < ActiveRecord::Migration
  def self.up
    add_column(:teachers, :photolocation_vote_map, :text)
    remove_column(:teachers, :current_photo_location)
    add_column(:teachers, :total_photo_votes, :integer)
    add_column(:teachers, :user_vote_map, :text)
    add_column(:teachers, :next_photo_name, :integer)
  end

  def self.down
    remove_column(:teachers, :photolocation_vote_map)
    add_column(:teachers, :current_photo_location, :string)
    remove_column(:teachers, :total_photo_votes)
    remove_column(:teachers, :user_vote_map)
    remove_column(:teachers, :next_photo_name)
  end
end
