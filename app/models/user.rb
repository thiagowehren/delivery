class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  enum :role, [:admin, :buyer, :seller]
  has_many :stores
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  class InvalidToken < StandardError; end


  def self.from_token(token)
      jwt_payload = JWT.decode(token, jwt_secret)
      user_payload = jwt_payload[0]
      
      if (user_payload["id"].present?)
        user = User.new
        user.attributes = user_payload
      else
        user_email = user_payload["email"]
        user = User.find_by(email: user_email.downcase)
      end

      user

      rescue JWT::ExpiredSignature
        raise InvalidToken.new
  end

  def self.token_for(user)
    payload = {id: user.id, email: user.email, role: user.role}
    # payload = {email: user.email, role: user.role}
    payload = payload.merge({exp: 1.hour.from_now.to_i})
    jwt_payload = JWT.encode(payload, jwt_secret)
  end
  
  private

  def self.jwt_secret
    @jwt_secret ||= Rails.application.credentials.devise[:jwt_secret_key]
  end
end
