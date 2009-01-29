class AddOtherToTeacherInfo < ActiveRecord::Migration
  def self.up
    add_column(:teacher_infos, :other, :text)
  end

  def self.down
    remove_column(:teacher_infos, :other)
  end
end
