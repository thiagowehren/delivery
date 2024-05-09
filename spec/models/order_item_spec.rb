require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe "associations" do
    it "should belong to an order, a product, and a store" do
      order = FactoryBot.create(:order_with_items)
      order_item = order.order_items.first

      expect(order_item.order).to eq(order)
      expect(order_item.product).to be_a(Product)
    end
  end

  describe "creating order_items" do
    it "should only have products from the same store as order" do
      order = FactoryBot.create(:order_with_items)
      order_item = order.order_items.first
      order_item_store = order_item.product.store
      expect(order_item_store).to eq(order.store)
    end

    it "should increase order_items by 1" do
      order = FactoryBot.create(:order)
      store = order.store
      product = store.products.last

      expect{
        FactoryBot.create(:order_item,order: order,product: product)
      }.to change { order.order_items.count }.by(1)
    end
  end

  describe "validations" do
    it "should validate that amount cannot be zero" do
      order = FactoryBot.create(:order_with_items)
      store = order.store
      product = store.products.last

      order_item_zero = FactoryBot.build(
        :order_item, 
        amount: 0, 
        order: order, 
        product: product
      )

      order_item_negative = FactoryBot.build(
        :order_item, 
        amount: -1, 
        order: order, 
        product: product
      )

      order_item_positive = FactoryBot.build(
        :order_item, 
        amount: 1, 
        order: order, 
        product: product
      )
      
      expect(order_item_zero).not_to be_valid
      expect(order_item_negative).not_to be_valid
      expect(order_item_positive).to be_valid
    end
  end
end
