class Order < ApplicationRecord    
    belongs_to :buyer, class_name: "User"
    belongs_to :store

    has_many :order_items
    has_many :products, through: :order_items

    validate :buyer_role

    state_machine initial: :created do
        event :accept do
            transition created: :accepted
        end

        event :dispatch do
            transition accepted: :dispatched
        end

        event :complete do
            transition dispatched: :completed
        end

        event :cancel do
            transition any => :cancelled, unless: :completed?
        end
    end

    def total_price
        order_items.sum(&:price).to_f
    end

    private

    def buyer_role
        if !buyer
            errors.add(:buyer, "should exists")
            return
        end

        if !buyer.buyer?
            errors.add(:buyer, "should be a `user.buyer`")
        end
    end

    def self.available_states
        state_machine.states.map(&:name)
    end

end
