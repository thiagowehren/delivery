FactoryBot.define do
    factory :store do
        name {"Example Store"}
        association :user, factory: :user

        factory :store_with_products do
            transient do
                products_count { 10 }
            end
    
            after(:create) do |store, eval|
                create_list(:product, eval.products_count, store: store)
                store.reload
            end
        end
        
    end
end