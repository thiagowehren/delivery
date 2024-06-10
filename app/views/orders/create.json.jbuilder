json.order do
	json.id @order.id
	json.total_price number_to_currency(@order.total_price)
	json.order_items @order.order_items do |item|
		json.amount item.amount
		json.total_price number_to_currency(item.price)
		json.product do
            json.partial! "products/product", locals: { product: item.product }
		end
	end
end