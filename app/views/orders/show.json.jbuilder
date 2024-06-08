json.order do
    json.partial! "orders/order", locals: { order: @order }
    json.order_items @order.order_items do |order_item|
        json.product do
            json.partial! "products/product", locals: { product: order_item.product }
            json.amount = order_item.amount
        end
    end
end