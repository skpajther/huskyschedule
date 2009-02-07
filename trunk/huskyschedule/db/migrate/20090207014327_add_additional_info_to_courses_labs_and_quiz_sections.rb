class AddAdditionalInfoToCoursesLabsAndQuizSections < ActiveRecord::Migration
  def self.up
    add_column(:courses, :additional_info, :text)
    add_column(:labs, :additional_info, :text)
    add_column(:quiz_sections, :additional_info, :text)
  end

  def self.down
    remove_column(:courses, :additional_info)
    remove_column(:labs, :additional_info)
    remove_column(:quiz_sections, :additional_info)
  end
end
