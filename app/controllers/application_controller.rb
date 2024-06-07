class ApplicationController < ActionController::Base
    rescue_from User::InvalidToken, with: :invalid_token
    before_action :set_locale!

    def invalid_token
        render json: { error: 'Token expired' }, status: :unauthorized
    end

    def current_user
        if request.format == Mime[:json]
            @user
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

    def authorize_admin_and_buyers!
        is_buyer = (current_user && current_user.buyer?) && current_credential.buyer?
        
        if !is_buyer && !current_user.admin?
            render json: {message: "Not authorized"}, 
            status: :unauthorized    
        end
    end

    def set_locale!
        if params[:locale].present?
            I18n.locale = params[:locale]       
       else
            I18n.locale = "pt-BR"
       end
    end
end
