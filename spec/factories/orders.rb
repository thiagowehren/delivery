FactoryBot.define do
  factory :order do
    association :buyer, factory: :buyer_user
    association :store, factory: :store_with_products

    factory :order_with_items do

      after(:create) do |order, evaluator|
        product_one = order.store.products.first
        product_two = order.store.products.second
        create(:order_item, order: order, product: product_one)
        create(:order_item, order: order, product: product_two)
      end
    end
  end
end
