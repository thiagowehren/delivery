class Product < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :store
  before_save :set_hidden_if_priceless
  scope :visible, -> { where(hidden: false) }
  validates :title, presence: true, length: {minimum: 1}
  has_one_attached :image
  has_many :orders, through: :order_items

  def thumbnail
    image.variant(resize_to_limit: [100, 100]).processed { |v| v.quality(50) }
  end

  def medium
    image.variant(resize_to_limit: [200, 200]).processed { |v| v.quality(70) }
  end

  def set_hidden_if_priceless
    return if self.hidden == true
    self.hidden = !(price.present? && price > 0)
  end
end
