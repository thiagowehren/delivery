class OrderItem < ApplicationRecord
    belongs_to :order
    belongs_to :product
    validate :store_product
    
    validates :amount, numericality: { greater_than: 0 }

    private

    def store_product
        if(product.store != order.store)
            errors.add(:product, "product should belong to `Store`: #{order.store.name} but it's from `Store`: #{product.store.name}")
        end
    end
end
