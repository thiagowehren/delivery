require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "associations" do
    it "should belong to a buyer user" do
      order = FactoryBot.create(:order)
      expect(order).to be_valid
      expect(order.buyer).to be_buyer
    end
  end
  
  describe "creating orders" do
    it "should create an order with no items" do
      order = FactoryBot.create(:order)
      expect(order).to be_valid
      expect(order.order_items).to be_empty
    end

    it "should create an order with items" do
      order = FactoryBot.create(:order_with_items)
      expect(order).to be_valid
      expect(order.order_items).not_to be_empty
    end
  end   
end
