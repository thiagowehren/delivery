module Expirable
    extend ActiveSupport::Concern

    NEVER_EXPIRES = 0

    included do
      attr_accessor :expires_in
      after_create :schedule_expiration
      after_update :schedule_expiration
    end
  
    private
  
    def schedule_expiration
      return unless expires_in.present?
      return if expires_in.to_i == NEVER_EXPIRES || expires_in.blank?
      expires_at = Time.current + expires_in.to_i.seconds
      self.update_column(:expires_at, expires_at)
  
      MarkAsExpiredJob.set(wait_until: expires_at).perform_later(id)
    end
  end
  