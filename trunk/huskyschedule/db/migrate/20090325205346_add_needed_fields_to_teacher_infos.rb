class AddNeededFieldsToTeacherInfos < ActiveRecord::Migration
  def self.up
    add_column(:teacher_infos, :total_confirmations, :integer)
    add_column(:teacher_infos, :confirmed_by, :text)
    add_column(:teacher_infos, :user_id, :integer)
  end

  def self.down
    remove_column(:teacher_infos, :total_confirmations)
    remove_column(:teacher_infos, :confirmed_by)
    remove_column(:teacher_infos, :user_id)
  end
end
