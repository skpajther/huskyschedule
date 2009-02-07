class ChangeBuildingIdToBuildingsInCoursesLabsAndQuizsecs < ActiveRecord::Migration
  def self.up
    remove_column(:courses, :building_id)
    add_column(:courses, :buildings, :text)
    remove_column(:labs, :building_id)
    add_column(:labs, :buildings, :text)
    remove_column(:quiz_sections, :building_id)
    add_column(:quiz_sections, :buildings, :text)
  end

  def self.down
    remove_column(:courses, :buildings)
    add_column(:courses, :building_id, :integer)
    remove_column(:labs, :buildings)
    add_column(:labs, :building_id, :integer)
    remove_column(:quiz_sections, :buildings)
    add_column(:quiz_sections, :building_id, :integer)
  end
end
