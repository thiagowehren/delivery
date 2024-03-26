class ProductsController < ApplicationController
    before_action :authenticate_user!

    def listing
        if !current_user.admin?
            flash[:notice] = "Denied Access!"
            redirect_to root_path #, notice: "Denied Access!"
        end
        
        @products = Product.includes(:store)
    end
end
