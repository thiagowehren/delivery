class Product < ApplicationRecord
  belongs_to :store

  has_many :orders, through: :order_items
end
