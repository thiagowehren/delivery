# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

admin = User.find_by(
    email: "adminSeed@example.com"
)

if !admin
    admin = User.new(
        email: "adminSeed@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :admin
    )
    admin.save!
end

["Bob Store", "Alice Store"].each do |store|
    store_email = "#{store.split.map { |s| s.downcase }.join(".")}@example.com"

    user = User.find_by(
        email: store_email
    )

    next if user

    user = User.new(
    email: store_email,
    password: "123456",
    password_confirmation: "123456",
    role: :seller
    )
    user.save!

    Store.find_or_create_by!(
        name: store, 
        user: user
    )
end

[
 "Massaman Curry",
 "Risotto with Seafood",
 "Tuna Sashimi",
 "Fish and Chips",
 "Pasta Carbonara"
].each do |dish|
    store = Store.find_by(name:"Bob Store")
    Product.find_or_create_by!(
        title: dish, store: store
    )
end

[
    "Mushroom Risotto",
    "Caesar Salad",
    "Mushroom Risotto",
    "Tuna Sashimi",
    "Chicken Milanese"
].each do |dish|
    store = Store.find_by(name:"Alice Store")
    Product.find_or_create_by!(
        title: dish, store: store
    )
end