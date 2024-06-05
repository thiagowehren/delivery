json.order do
	json.id @order.id
	json.total_price @order.total_price
	json.order_items @order.order_items do |item|
		json.product do
		json.product_id item.product.id
		json.amount item.amount
		json.total_price item.price
		end
	end
end