class Product < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :store

  has_many :orders, through: :order_items
end
