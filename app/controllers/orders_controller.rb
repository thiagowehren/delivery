class OrdersController < ApplicationController
    skip_forgery_protection
    before_action :authenticate!
    before_action :authorize_admin_and_buyers!, except: [:store_orders, :show]

    before_action :set_order, only: %i[ show ]

    def index
        page = params.fetch(:page, 1)
        @orders = Order.where(buyer: current_user).order(created_at: :desc)
        @orders = @orders.page(page)
        render'orders/index', status: :ok
    end

    def show
      if @order.store.user != current_user && @order.buyer != current_user
        respond_to do |format|
          format.json { render json: { error: { message: "This Order doesn't belong to you." }}, status: :unprocessable_entity }
        end
        return
      end
    end

    def create
        order_items_params = Array.wrap(order_params[:order_items])
      
        if current_user.admin?
          @order = Order.new(store_id: order_params[:store_id], buyer_id: order_params[:buyer_id])
        else
          @order = Order.new(store_id: order_params[:store_id], buyer: current_user)
        end
      
        order_item_list = []
      
        order_items_params.each do |order_item|
          order_item = order_item.permit(:product_id, :amount)
          order_item_obj = OrderItem.new(order_item)
          order_item_obj.order = @order
          order_item_list << order_item_obj
      
          unless order_item_obj.valid?
            @order.errors.add(:base, "Failed to add one of the items to the order. [item_id: #{order_item_obj.product_id}]")
            @order.errors.add(:causes, order_item_obj.errors.full_messages.to_sentence)
            render_errors_and_return
            return
          end
        end
      
        if order_item_list.empty?
          @order.errors.add(:base, "Order must have at least one item")
          render_errors_and_return
          return
        end
      
        if @order.save
          order_item_list.map(&:save)
      
          respond_to do |format|
            format.html { redirect_to store_store_orders_path(order_params[:store_id]), alert: "Unauthorized" }
            format.json { render template: 'orders/create', status: :created }
          end
        else
          render_errors_and_return
          return
        end
    end

    def update
    end

    def destroy
    end

    #GET store/:id/orders
    def store_orders
        page = params.fetch(:page, 1)

        begin
          store = Store.includes(:user).find(params[:store_id])
        rescue ActiveRecord::RecordNotFound
          respond_to do |format|
            format.html { render 'stores/store_not_found', status: :not_found }
            format.json { render 'stores/store_not_found', status: :not_found }
          end
          return
        end

        # admin or store owner
        unless current_user == store.user || current_user.admin?
          respond_to do |format|
            format.html { redirect_to stores_url, alert: "User doesn't match with store Owner" }
            format.json { render json: {error: "Unauthorized"}, status: :unauthorized }
          end
          return
        end

        @orders = store.orders.order(created_at: :desc).includes(:order_items)
        @orders = @orders.page(page)

        render 'orders/store_orders', status: :ok
    end

    private

    def set_order
      @order = Order.includes(store: :user, buyer: {}, order_items: :product).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.json { head :no_content, status: :not_found }
      end
    end

    def render_errors_and_return
        error_message = "Errors: "
        error_message += @order.errors.full_messages.join(", ")
        
        respond_to do |format|
          format.html { redirect_to orders_new_store_url(order_params[:store_id]), alert: error_message }
          format.json { render json: { errors: @order.errors }, status: :unprocessable_entity }
        end
    end

    def order_params
        if current_user.admin?
            params.require(:order).permit(
                :store_id,
                :buyer_id,
                order_items: [:product_id, :amount]
            )
        else
            params.require(:order).permit(
                :store_id,
                order_items: [:product_id, :amount]
            )
        end
    end
end