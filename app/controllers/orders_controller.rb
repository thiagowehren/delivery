class OrdersController < ApplicationController
    skip_forgery_protection
    before_action :authenticate!
    before_action :only_buyers!

    def index
        @orders = Order.where(buyer: current_user).order(created_at: :desc)
        render'orders/index', status: :ok
    end

    def create
        if order_params[:store_id].blank? || order_params[:order_items].blank? || order_params[:order_items].empty?
            render json: { status: 400, error: "Bad Request" }, status: :bad_request
            return
        end

        @order = Order.new(store_id: order_params[:store_id], buyer: current_user)

        order_item_list = []
        order_items_params = order_params[:order_items]
        
        order_items_params.each do |order_item|
            order_item = OrderItem.new(order_item)
            order_item.order = @order
            order_item_list << order_item

            if !order_item.valid?
                @order.errors.add(:base, "Failed to add one of the items to the order. [item_id: #{order_item.product_id}]")
                @order.errors.add(:causes, "#{order_item.errors.full_messages}")
                
                # p order_item.errors.full_messages
                render json: { errors: @order.errors }, status: :unprocessable_entity
                return
            end
        end

        if @order.save
            order_item_list.map(&:save)

            render template: 'orders/create', status: :created
        else
            render json: {errors: @order.errors}, status: :unprocessable_entity
        end
    end

    def update
    end

    def destroy
    end

    private

    def order_params
        params.require(:order).permit(
            :store_id,
            order_items: [:product_id, :amount]
        )
    end
end