class CreateTeacherInfos < ActiveRecord::Migration
  def self.up
    create_table :teacher_infos do |t|
      t.integer :teacher_id
      t.string :office
      t.integer :sex
      t.string :website
      t.string :email
      t.string :department

      t.timestamps
    end
  end

  def self.down
    drop_table :teacher_infos
  end
end
