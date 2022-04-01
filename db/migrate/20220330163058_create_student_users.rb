class CreateStudentUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :student_users do |t|
      t.string :userid
      t.string :name
      t.string :gender
      t.string :birthday
      t.string :nation
      t.string :id_number
      t.string :political
      t.string :bank_card
      t.string :mobile
      t.string :email
      t.string :education_system
      t.string :student_category
      t.string :cultivation_level
      t.string :enter_school
      t.string :leave_school
      t.string :student_status
      t.string :at_school
      t.string :college
      t.string :major
      t.string :current_grade
      t.string :classes
      t.string :instructor_name
      t.string :instructor_id
      t.string :instructor_mobile
      t.string :campus
      t.string :dormitory
      t.string :room
      t.string :bed
      t.string :flag

      t.timestamps
    end
  end
end
