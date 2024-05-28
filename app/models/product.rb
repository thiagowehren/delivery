class Product < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :store
  has_one_attached :image
  validates :title, presence: true, length: {minimum: 1}

  has_many :orders, through: :order_items

  def thumbnail
    image.variant(resize_to_limit: [100, 100]).processed { |v| v.quality(50) }
  end

  def medium
    image.variant(resize_to_limit: [200, 200]).processed { |v| v.quality(70) }
  end
end
