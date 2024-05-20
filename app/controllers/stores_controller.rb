class StoresController < ApplicationController
  skip_forgery_protection only: %i[create update]
  before_action :authenticate!
  before_action :set_store, only: %i[ show edit update destroy ]

  # GET /stores or /stores.json
  def index
    user = current_user()
    if user.admin? || user.buyer?
      @stores = Store.all 
    else
      @stores = Store.where(user: user[:id])
    end
  end

  # GET /stores/1 or /stores/1.json
  def show
    return if redirected_seller_cause_not_owner?
    @store = Store.find(params[:id])
  end

  # GET /stores/new
  def new
    if current_user.buyer?
      respond_to do |format|
        format.html { redirect_to stores_url, notice: "Unauthorized" }
        format.json { head :unauthorized }
      end
    end
    @store = Store.new
    if current_user.admin?
      @sellers = User.where(role: :seller)
    end
  end

  # GET /stores/1/edit
  def edit
    return if redirected_cause_user_not_owner_and_not_admin?
    #TODO
    #edit name
    #edit image
    #set to hidden
  end

  # POST /stores
  def create
    @store = Store.new(store_params)
    if !current_user.admin?
    @store.user = current_user
    end

    respond_to do |format|
      if @store.save
        format.html { redirect_to store_url(@store), notice: "Store was successfully created." }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stores/1
  def update
    return if redirected_cause_user_not_owner_and_not_admin?
    
    respond_to do |format|
      if @store.update(store_params)
        format.html { redirect_to store_url(@store), notice: "Store was successfully updated." }
        format.json { render :show, status: :ok, location: @store }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1
  def destroy
    return if redirected_cause_user_not_owner_and_not_admin?

    ActiveRecord::Base.transaction do
      @store.products.destroy_all
      @store.destroy!
    end

    respond_to do |format|
      format.html { redirect_to stores_url, notice: "Store was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = Store.find(params[:id]) 
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.html { render 'stores/store_not_found', status: :not_found }
          format.json { render 'stores/store_not_found', status: :not_found }
        end
    end

    # Only allow a list of trusted parameters through.
    def store_params
        required = params.require(:store)
      if current_user.admin?
        required.permit(:name,:user_id)
      else
        required.permit(:name)
      end
    end

    #pair with early return "return if true" to prevent DoubleRenderError
    def redirected_cause_user_not_owner_and_not_admin?
      redirected_bool = false

      if current_user != @store.user && !current_user.admin?
        redirected_bool = true

        respond_to do |format|
          format.html { redirect_to stores_url, alert: "User doesn't match with store Owner" }
          format.json { render json: {error: "Unauthorized"}, status: :unauthorized  }
        end
      end
      
      redirected_bool
    end

    #pair with early return "return if true" to prevent DoubleRenderError
    def redirected_seller_cause_not_owner?
      redirected_bool = false

      if current_user.seller? && (current_user != @store.user)
        redirected_bool = true

        respond_to do |format|
          format.html { redirect_to stores_url, alert: "User doesn't match with store Owner" }
          format.json { render json: {error: "Unauthorized"}, status: :unauthorized  }
        end
      end
      
      redirected_bool
    end

end
