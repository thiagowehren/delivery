class Store < ApplicationRecord
    acts_as_paranoid

    belongs_to :user
    before_validation :ensure_seller
    has_many :products, dependent: :destroy
    has_many :orders
    has_one_attached :image
    scope :visible, -> { where(hidden: false) }
    validates :name, presence: true, length: {minimum: 3}

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
          default_image = Rails.root.join("app", "assets", "images", "shop-default-256.png")
          if File.exist?(default_image)
            ActiveStorage::Attached::One.new(:image, self).attach(io: File.open(default_image), filename: "shop-default-256.png", content_type: "image/png")
          else
            Rails.logger.error("File not found from Store model: #{default_image}")
            nil
          end
        end
    end

    private

    def ensure_seller
        self.user = nil if self.user && !self.user.seller?
    end

end
