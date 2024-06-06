class Product < ApplicationRecord
  include Expirable
  acts_as_paranoid

  belongs_to :store
  before_save :set_hidden_if_priceless
  scope :visible, -> { where(hidden: false) }
  scope :not_expired, -> { where(expired: false) }
  validates :title, presence: true, length: {minimum: 1}
  has_one_attached :image
  has_many :orders, through: :order_items

  def thumbnail
    image.variant(resize_to_limit: [100, 100]).processed { |v| v.quality(50) }
  end

  def medium
    image.variant(resize_to_limit: [200, 200]).processed { |v| v.quality(70) }
  end

  def image_with_default
    if image.attached?
      image
    else
      default_image = Rails.root.join("app", "assets", "images", "dish-default-256.png")
      if File.exist?(default_image)
        ActiveStorage::Attached::One.new(:image, self).attach(io: File.open(default_image), filename: "dish-default-256.png", content_type: "image/png")
      else
        Rails.logger.error("File not found from Product model: #{default_image}")
        nil
      end
    end
  end

  def set_hidden_if_priceless
    return if self.hidden == true
    self.hidden = !(price.present? && price > 0)
  end
end
