class ModifyMobile < ApplicationRecord
    validates :userid, presence: { message: '学号不能为空！' }
    validates :name, presence: { message: '姓名不能为空！' }
    validates :mobile, format: { with: /(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}/, message: "手机号格式不正确！" }
    validates :idnumber, presence: { message: '身份证不能为空！' }
    after_create_commit -> { broadcast_append_to @modify_mobile }
end
