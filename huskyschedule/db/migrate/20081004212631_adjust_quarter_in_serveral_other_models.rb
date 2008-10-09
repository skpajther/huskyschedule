class AdjustQuarterInServeralOtherModels < ActiveRecord::Migration
  def self.up
    rename_column(:courses, :quarter, :quarter_id)
  end

  def self.down
    rename_column(:courses, :quarter_id, :quarter)
  end
end
