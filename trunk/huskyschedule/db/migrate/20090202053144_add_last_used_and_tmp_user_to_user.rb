class AddLastUsedAndTmpUserToUser < ActiveRecord::Migration
  def self.up
    add_column(:users, :last_used, :datetime)
    add_column(:users, :tmp_user, :boolean)
  end

  def self.down
    remove_column(:users, :last_used)
    remove_column(:users, :tmp_user)
  end
end
