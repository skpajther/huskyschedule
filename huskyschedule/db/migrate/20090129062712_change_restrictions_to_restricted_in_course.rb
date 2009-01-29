class ChangeRestrictionsToRestrictedInCourse < ActiveRecord::Migration
  def self.up
    rename_column(:courses, :restrictions, :restricted)
  end

  def self.down
    rename_column(:courses, :restricted, :restrictions)
  end
end
