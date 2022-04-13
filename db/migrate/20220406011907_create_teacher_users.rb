class CreateTeacherUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :teacher_users do |t|
      t.string :userid
      t.string :name
      t.string :department
      t.string :position
      t.string :mobile
      t.string :gender

      t.timestamps
    end
  end
end
