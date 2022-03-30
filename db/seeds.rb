# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
2000.times do
    Account.create({ userid: Faker::IDNumber.unique.brazilian_id, name: Faker::Name.name, department: Faker::Company.name, position: Faker::Company.industry, mobile: Faker::Internet.unique.email, gender: Faker::Gender.binary_type })
end
