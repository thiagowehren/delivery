class OrdersController < ApplicationController
    skip_forgery_protection
    before_action :authenticate!
    before_action :authorize_admin_and_buyers!, except: [:store_orders]

    def index
        @orders = Order.where(buyer: current_user).order(created_at: :desc)
        render'orders/index', status: :ok
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
        store = Store.find(params[:store_id])
        @orders = store.orders.order(created_at: :desc).includes(:order_items)

        render 'orders/store_orders', status: :ok
    end

    private

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