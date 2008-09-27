# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080925032735) do

  create_table "buildings", :force => true do |t|
    t.string   "name"
    t.integer  "lat",        :limit => 10, :precision => 10, :scale => 0
    t.integer  "lng",        :limit => 10, :precision => 10, :scale => 0
    t.string   "abbrev"
    t.integer  "uw_lat",     :limit => 10, :precision => 10, :scale => 0
    t.integer  "uw_lng",     :limit => 10, :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id",  :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_ratings", :force => true do |t|
    t.integer  "quarter_taken",  :limit => 11
    t.integer  "teacher_id",     :limit => 11
    t.integer  "rating",         :limit => 11
    t.text     "pros"
    t.text     "cons"
    t.text     "other_thoughts"
    t.text     "rating_name"
    t.integer  "user_id",        :limit => 11
    t.string   "class_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", :force => true do |t|
    t.integer  "sln",               :limit => 11
    t.integer  "teacher_id",        :limit => 11
    t.string   "title"
    t.integer  "number",            :limit => 11
    t.integer  "status",            :limit => 11
    t.integer  "students_enrolled", :limit => 11
    t.integer  "enrollment_space",  :limit => 11
    t.integer  "credits",           :limit => 11
    t.boolean  "restrictions"
    t.string   "deptabriev"
    t.text     "notes"
    t.text     "credit_type"
    t.string   "section"
    t.text     "times"
    t.text     "description"
    t.boolean  "crnc"
    t.integer  "parent_id",         :limit => 11
    t.integer  "quarter",           :limit => 11
    t.integer  "building_id",       :limit => 11
    t.string   "room"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "labs", :force => true do |t|
    t.integer  "sln",               :limit => 11
    t.integer  "teacher_id",        :limit => 11
    t.integer  "status",            :limit => 11
    t.integer  "students_enrolled", :limit => 11
    t.integer  "enrollment_space",  :limit => 11
    t.boolean  "restrictions"
    t.text     "notes"
    t.string   "section"
    t.text     "times"
    t.text     "description"
    t.boolean  "crnc"
    t.integer  "parent_id",         :limit => 11
    t.integer  "building_id",       :limit => 11
    t.string   "room"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quiz_sections", :force => true do |t|
    t.integer  "sln",               :limit => 11
    t.integer  "teacher_id",        :limit => 11
    t.integer  "status",            :limit => 11
    t.integer  "students_enrolled", :limit => 11
    t.integer  "enrollment_space",  :limit => 11
    t.boolean  "restrictions"
    t.text     "notes"
    t.string   "section"
    t.text     "times"
    t.text     "description"
    t.boolean  "crnc"
    t.integer  "parent_id",         :limit => 11
    t.integer  "building_id",       :limit => 11
    t.string   "room"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teacher_ratings", :force => true do |t|
    t.integer  "teacher_id",       :limit => 11
    t.integer  "course_taught_id", :limit => 11
    t.integer  "rating",           :limit => 11
    t.text     "pros"
    t.text     "cons"
    t.text     "other_thoughts"
    t.string   "name"
    t.integer  "user_id",          :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teachers", :force => true do |t|
    t.string   "name"
    t.string   "current_photo_location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

end
