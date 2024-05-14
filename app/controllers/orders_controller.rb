class OrdersController < ApplicationController
    skip_forgery_protection
    before_action :authenticate!
    before_action :only_buyers!

    def index
        @orders = Order.where(buyer: current_user)
        render'orders/index', status: :ok
    end

    def create
        @order = Order.new(order_params)
        # @order = Order.new(order_params) { |o| o.buyer = current_user}
        @order.buyer = current_user

        if @order.save
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
        params.require(:order).permit([:store_id])
    end
end