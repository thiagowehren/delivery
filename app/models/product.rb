class Product < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :store
  validates :title, presence: true, length: {minimum: 1}

  has_many :orders, through: :order_items
end
