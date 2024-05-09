FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    amount { 1 }
    price { product.price }
  end
end
