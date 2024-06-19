class StoresController < ApplicationController
  skip_forgery_protection only: %i[create update destroy]
  before_action :authenticate!
  before_action :set_store, only: %i[ show edit update destroy new_order store_daily_revenue]
  before_action :redirect_if_not_admin_or_owner, only: [:edit, :update, :destroy]
  before_action :redirect_if_not_store_owner, only: [:show]

  # GET /stores or /stores.json
  def index
    page = params.fetch(:page, 1)
    user = current_user()
    if user.admin?
      @stores = Store.includes(:image_attachment => :blob) 
    elsif user.buyer?
      @stores = Store.visible.includes(:image_attachment => :blob) 
    else
      @stores = Store.includes(:image_attachment => :blob).where(user: user[:id])
    end
    @stores = @stores.page(page)
  end

  # GET /stores/1 or /stores/1.json
  def show
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

  # GET /stores/:id/orders/new   form: POST => buyers/orders
  def new_order
    if current_user.admin?
      @order = Order.new
      @products = Product.visible.not_expired.where(store:@store)
      @buyers = User.where(role: :buyer)
    else
      respond_to do |format|
        format.html { redirect_to store_path(@store), alert: "Unauthorized" }
        format.json { head :unauthorized }
      end
    end
  end

  # GET /stores/1/edit
  def edit
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

    ActiveRecord::Base.transaction do
      @store.destroy!
    end

    respond_to do |format|
      format.html { redirect_to stores_url, notice: "Store was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def store_daily_revenue
    unless current_user.admin? || current_user == @store.user
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end

    revenue = Order.joins(:order_items)
                .where('orders.created_at >= ? AND orders.store_id = ?', 30.days.ago, @store.id)
                .group_by_day('orders.created_at')
                .sum('order_items.price * order_items.amount')

    render json: revenue
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store

      if action_name == "new_order"
        @store = Store.visible.find(params[:id])
      else
        @store  = if current_user.buyer?
                    Store.visible.includes(:image_attachment => :blob).find(params[:id])
                  else
                    Store.includes(:image_attachment => :blob).find(params[:id])
                  end
      end
      

      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.html { render 'stores/store_not_found', status: :not_found }
          format.json { render 'stores/store_not_found', status: :not_found }
        end
    end

    def redirect_if_not_admin_or_owner
      return if current_user == @store.user || current_user.admin?
  
      respond_to do |format|
        format.html { redirect_to stores_url, alert: "User doesn't match with store Owner" }
        format.json { render json: {error: "Unauthorized"}, status: :unauthorized }
      end
    end

    def redirect_if_not_store_owner
      return unless current_user.seller? && current_user != @store.user
  
      respond_to do |format|
        format.html { redirect_to stores_url, alert: "User doesn't match with store Owner" }
        format.json { render json: {error: "Unauthorized"}, status: :unauthorized }
      end
    end

    def store_params
      required = params.require(:store)
      if current_user.admin?
        required.permit(:name, :user_id, :hidden, :image)
      else
        required.permit(:name, :hidden, :image)
      end
    end
end
