FactoryBot.define do
  factory :seller_user, class: User do
    # Devise
    sequence(:email) { |n| "factorybotselleruser#{n}@example.com" }
    password { "123456" }
    password_confirmation { "123456" }
    role { :seller }
  end

  factory :buyer_user, class: User do
    # Devise
    sequence(:email) { |n| "factorybotbuyeruser#{n}@example.com"}
    password { "123456" }
    password_confirmation { "123456" }
    role { :buyer }
  end

  factory :admin_user, class: User do
    # Devise
    sequence(:email) { |n| "factorybotadminser#{n}@example.com"}
    password { "123456" }
    password_confirmation { "123456" }
    role { :admin }
  end
end
