FactoryBot.define do
    factory :user do
      #Devise
      sequence(:email) { |n| "factorybotuser#{n}@example.com"}
      password {"123456"}
      password_confirmation {"123456"}
    end
end