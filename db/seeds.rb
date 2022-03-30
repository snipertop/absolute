# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
1.times do
    Account.create([
        { userid: "1703018", name: "阮琳赈", department: "信息与设备管理处", position: "", mobile: "15515733013", gender: "男" },
        { userid: "1703006", name: "彭磊", department: "信息与设备管理处", position: "信息化管理科科长", mobile: "13676926355", gender: "男" },
        { userid: "1703017", name: "耿中宝", department: "信息与设备管理处", position: "助理工程师", mobile: "15039090168", gender: "男" },
        { userid: "0101126", name: "陈茜", department: "工商管理学院", position: "教师", mobile: "15896807424", gender: "女" }
    ])
end
