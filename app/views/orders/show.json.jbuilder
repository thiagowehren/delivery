json.order do
    json.partial! "orders/order", locals: { order: @order }
    json.order_items @order.order_items do |order_item|
        json.amount order_item.amount
        json.total_price number_to_currency(order_item.price)
        json.product do
            json.partial! "products/product", locals: { product: order_item.product }
        end
    end
end