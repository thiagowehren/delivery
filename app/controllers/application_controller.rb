class ApplicationController < ActionController::Base
    def current_user
        if request.format == Mime[:json]
            render json: {id: @user.id, email: @user.email, role: @user.role},
            status: :ok
        else
            #Devise
            super
        end
    end
    
    def authenticate!
        if request.format == Mime[:json]
            check_token!
        else
            #Devise
            authenticate_user!
        end
    end

    private

    def check_token!
        user = authenticate_with_http_token { |token, options| User.from_token(token)}
        if user
            @user = user
        else
            render json: {message: "Not authorized"}, 
            status: :unauthorized
        end
    end

    def current_credential
        return nil if request.format != Mime[:json]
        Credential.find_by(key: request.headers["X-API-KEY"]) || Credential.new
    end
end
