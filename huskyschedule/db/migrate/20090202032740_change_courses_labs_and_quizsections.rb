class ChangeCoursesLabsAndQuizsections < ActiveRecord::Migration
  def self.up
    rename_column(:courses, :deptabriev, :deptabbrev)
  end

  def self.down
    rename_column(:courses, :deptabbrev, :deptabriev)
  end
end
