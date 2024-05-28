class ProductsController < ApplicationController
	skip_forgery_protection only: %i[create update]

	before_action :authenticate!

	before_action :set_store, except: %i[listing redirect_to_store_product]
	before_action :set_product, only: %i[show edit update destroy redirect_to_store_product]

	before_action :authorize_admin, only: %i[listing]
	before_action :authorize_store_owner_and_admin, only: %i[create new edit update destroy]
	before_action :authorize_buyer_store_owner_and_admin, only: %i[show index]

  # GET /listing
	def listing
		@products = Product.includes(:store, :image_attachment => :blob)
	end

  # GET store/1/products/1 or store/1/products/1.json
	def show
		if @product.store_id != @store.id
			respond_to do |format|
				format.html { redirect_to store_products_path(@store), alert: "Product is not from this store." }
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
		@products = @store.products.includes(:image_attachment => :blob)
	end

  # GET /store/1/products/new
	def new
		@product = Product.new(store: @store)
	end

  # GET /store/1/products/1.edit
	def edit
	end

  # POST store/1/products
	def create
		@product = @store.products.new(product_params)

		respond_to do |format|
			if @product.save
				format.html { redirect_to store_products_path(@store), notice: "Product was successfully created." }
				format.json { render :show, status: :created, location: store_product_url(@store, @product) }
			else
				format.html { render :new, status: :unprocessable_entity }
				format.json { render json: @product.errors, status: :unprocessable_entity }
			end
		end
	end

  # PATCH/PUT store/1/products/1
	def update

		respond_to do |format|
			if @product.update(product_params)
				format.html { redirect_to store_products_path(@product.store), notice: "Product was successfully updated." }
				format.json { render :show, status: :ok, location: store_product_url(@store, @product) }
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
			format.json { head :no_content }
		end
	end

	def set_product
		@product = Product.includes(:image_attachment => :blob).find(params[:id])
	rescue ActiveRecord::RecordNotFound
		respond_to do |format|
			format.html { render 'products/product_not_found', status: :not_found }
			format.json { render 'products/product_not_found', status: :not_found }
		end
	end

  #get '/products/:id' => redirect_to ''stores/:store_id/products/:id'
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

	def authorize_store_owner_and_admin
		return if current_user == @store.user || current_user.admin?

		respond_to do |format|
			format.html { redirect_to stores_url, alert: "User doesn't match with store Owner." }
			format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
		end
	end

	def authorize_buyer_store_owner_and_admin
		return if current_user.buyer? || current_user.admin?
		return if current_user == @store.user

		respond_to do |format|
			format.html { redirect_to stores_url, alert: "User doesn't match with store Owner." }
			format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
		end
	end

	def authorize_admin
		return if current_user.admin?

		respond_to do |format|
			format.html do
			flash[:alert] = "Unauthorized."
			redirect_to stores_path
			end
			format.json { render json: { error: "Unauthorized." }, status: :unauthorized }
		end
	end

	def product_params
		params.require(:product).permit(:title, :price, :image)
		# params.require(:product).permit(:title, :price, :active, :image)
	end
end
