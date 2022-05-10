# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_05_07_073409) do
  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "userid"
    t.string "name"
    t.string "department"
    t.string "position"
    t.string "mobile"
    t.string "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "modify_mobiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "userid"
    t.string "name"
    t.string "mobile"
    t.string "idnumber"
    t.string "status"
    t.string "reviewer"
    t.string "wx_mobile"
    t.string "wx_status"
    t.string "rz_mobile"
    t.string "rz_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "student_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "userid"
    t.string "name"
    t.string "gender"
    t.string "birthday"
    t.string "nation"
    t.string "id_number"
    t.string "political"
    t.string "bank_card"
    t.string "mobile"
    t.string "email"
    t.string "education_system"
    t.string "student_category"
    t.string "cultivation_level"
    t.string "enter_school"
    t.string "leave_school"
    t.string "student_status"
    t.string "at_school"
    t.string "college"
    t.string "major"
    t.string "current_grade"
    t.string "classes"
    t.string "instructor_name"
    t.string "instructor_id"
    t.string "instructor_mobile"
    t.string "campus"
    t.string "dormitory"
    t.string "room"
    t.string "bed"
    t.string "flag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teacher_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "userid"
    t.string "name"
    t.string "department"
    t.string "position"
    t.string "mobile"
    t.string "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
