class AddVariableCreditToCourse < ActiveRecord::Migration
  def self.up
    add_column(:courses, :variable_credit, :integer)
  end

  def self.down
    remove_column(:courses, :variable_credit)
  end
end
