class CreateModifyMobiles < ActiveRecord::Migration[7.0]
  def change
    create_table :modify_mobiles do |t|
      t.string :userid
      t.string :name
      t.string :mobile
      t.string :idnumber
      t.string :status
      t.string :reviewer
      t.string :wx_mobile
      t.string :wx_status
      t.string :rz_mobile
      t.string :rz_status

      t.timestamps
    end
  end
end
