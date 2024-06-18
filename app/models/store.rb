class Store < ApplicationRecord
    acts_as_paranoid
    searchkick
    
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
        nil
      end
    end

    private

    def ensure_seller
        self.user = nil if self.user && !self.user.seller?
    end

end
