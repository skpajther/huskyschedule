class CreateCategoryEdges < ActiveRecord::Migration
  def self.up
    create_table "category_edges" do |t|
      t.column "parent_id", :integer, :null => false
      t.column "child_id",   :integer, :null => false
    end
  end

  def self.down
    drop_table :category_edges
  end
end
