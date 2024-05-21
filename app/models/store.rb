class Store < ApplicationRecord
    acts_as_paranoid

    belongs_to :user
    before_validation :ensure_seller
    has_many :products, dependent: :destroy
    validates :name, presence: true, length: {minimum: 3}

    private

    def ensure_seller
        self.user = nil if self.user && !self.user.seller?
    end
end
