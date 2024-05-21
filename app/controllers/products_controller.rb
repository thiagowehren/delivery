class ProductsController < ApplicationController
    # before_action :authenticate_user!
    before_action :authenticate!
    before_action :set_product, only: %i[ show edit update destroy redirect_to_store_product]
    before_action :set_store, only: %i[ new create show index ]
		before_action :redirect_if_not_admin_or_owner, only: [:index, :new, :edit, :create, :update, :destroy]
		before_action :redirect_seller_if_not_store_owner, only: [:show]

    def listing
			if !current_user.admin?
				respond_to do |format|
					format.html do
						flash[:notice] = "Unauthorized."
						redirect_to root_path
					end
					format.json { render json: { error: "Unauthorized." }, status: :unauthorized }
				end
			end

			@products = Product.includes(:store)
		end

	# GET store/1/products/1 or store/1/products/1.json
		def show

			if @product.store_id != @store.id
				respond_to do |format|
					format.html { redirect_to store_path(params[:store_id]), alert: "Product is not from this store." }
					format.json { render json: { error: { message: "Product is not from this store." }}, status: :unprocessable_entity }
				end
				return
			end

			respond_to do |format|
				format.html
				format.json do
					product_json = @product.as_json(only: [:id, :title, :price])
					product_json['store_url'] = store_url(@product.store, format: :json)
					render json: product_json
				end
			end
		end
	
  # GET /store/1/products or /store/1/products.json
		def index
			@products = @store.products
		end

  # GET /store/1/products/new
    def new
		@product = Product.new(store: @store)
    end

	# GET /store/1/products/1.edit
		def edit
			@store = @product.store
		end

  # POST store/1/products
    def create
			@product = @store.products.new(product_params)

			respond_to do |format|
					if @product.save
							format.html { redirect_to store_products_path(@store), notice: "Product was successfully created." }
							format.json { render :show, status: :created, location: @store }
					else
							format.html { render :new, status: :unprocessable_entity }
							format.json { render json: @product.errors, status: :unprocessable_entity }
					end
			end
    end

	# PATCH/PUT store/1/products/1
		def update
			#edit image
			#set to hidden

			respond_to do |format|
				if @product.update(product_params)
						format.html { redirect_to store_products_path(@product.store), notice: "Product was successfully updated." }
						format.json { render :show, status: :ok, location: @product }
				else
						format.html { render :edit, status: :unprocessable_entity }
						format.json { render json: @product.errors, status: :unprocessable_entity }
				end
			end
		end

	# DELETE store/1/products/1
		def destroy

			@product.destroy!
			respond_to do |format|
				format.html { redirect_to store_products_path(@product.store), notice: "Product was successfully updated." }
				format.json { render :show, status: :ok, location: @product }
			end
		end

    def set_product
			@product = Product.find(params[:id])

			rescue ActiveRecord::RecordNotFound
				respond_to do |format|
					format.html do
						flash[:alert] = "Product not found."
						if params[:store_id].present?
							redirect_to store_products_path(params[:store_id]) 
						else
							redirect_to stores_path
						end
					end
          format.json { render 'products/product_not_found', status: :not_found }
			end
    end

		def redirect_to_store_product
			@store = @product.store

			redirect_to store_product_path(@store, @product)
		end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_store
			@store = Store.find(params[:store_id])
      
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.html { render 'stores/store_not_found', status: :not_found }
          format.json { render 'stores/store_not_found', status: :not_found }
        end
		end

    def redirect_if_not_admin_or_owner
			return if current_user == @store.user || current_user.admin?
	
			respond_to do |format|
				format.html { redirect_to stores_url, alert: "Product or Store is not yours." }
				format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
			end
		end

		def redirect_seller_if_not_store_owner
			return if current_user.buyer? || current_user.admin?
			return if current_user == @store.user
	
			respond_to do |format|
				format.html { redirect_to stores_url, alert: "Product or Store is not yours." }
				format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
			end
		end

    def product_params
        params.require(:product).permit(:title, :price)
        # params.require(:product).permit(:title, :active, :price)
    end
end
