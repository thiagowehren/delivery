class RegistrationsController < ApplicationController
    skip_forgery_protection only: [:create, :me, :sign_in]
    # skip_before_action :verify_authenticity_token
    before_action :authenticate!, only: [:me]
    rescue_from User::InvalidToken, with: :not_authorized

    def me
        current_user()
    end

    def sign_in
        user = User.find_by(email: sign_in_params[:email])
        if !user || !user.valid_password?(sign_in_params[:password])
            render json: {error: "Invalid email or password. Please make sure you've entered the correct credentials."}, 
            status: :unauthorized
        else
            token = User.token_for(user)
            render json: {email: user.email, token: token},
            status: :ok
        end
    end

    def create
        @user = User.new(user_params)
        token = User.token_for(@user)
        render json: {"email": @user.email, token: token}, status: :ok if @user.save
    end

    private

    def sign_in_params
        params.require(:login).permit(:email, :password)
    end

    def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :role)
    end
    
    def not_authorized(e)
      render json: {message: "Unauthorized"}, 
              status: :unauthorized   
    end
end
