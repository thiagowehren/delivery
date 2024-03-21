FactoryBot.define do
    factory :product do
        sequence(:title) { |n| "product_example_#{n.to_s.rjust(3, '0')}" }
        price { 5.00 }
        
        association :store, factory: :store
    end
end