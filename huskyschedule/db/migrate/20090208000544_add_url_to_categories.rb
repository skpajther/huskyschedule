class AddUrlToCategories < ActiveRecord::Migration
  def self.up
    add_column(:categories, :url, :text)
  end

  def self.down
    remove_column(:categories, :url)
  end
end
