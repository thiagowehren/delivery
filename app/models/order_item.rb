class OrderItem < ApplicationRecord
    belongs_to :order
    belongs_to :product, -> { with_deleted }
    validate :store_product
    
    validates :amount, numericality: { greater_than: 0 }

    private

    def store_product
        return if product.nil?
        return if order.nil?

        if (product.store.nil? || order.store.nil?)
            errors.add(:store, "doens't exist.")
            return
        end

        if (amount.present?)
            if(product.price.nil?)
                errors.add(:product, "have no set price yet. Therefore is not visible and invalid.")
                return
            end

            self.price = amount * product.price
        end

        if (product.store != order.store)
            errors.add(:product, "should be from `Store`: #{order.store.id},  #{order.store.name} but it's from `Store`: #{product.store.id}, #{product.store.name}")
            return
        end
        
        if (product.expired)
            errors.add(:product, "is not visible.")
            return
        end

                
        if (product.hidden)
            errors.add(:product, "is not visible.")
            return
        end

        if (order.store.hidden)
            errors.add(:store, "is not visible.")
            return
        end
    end
end
