json.order do
	json.id @order.id
	json.order_items @order.order_items do |item|
		json.product do
		json.product_id item.product.id
		json.amount item.amount
		json.product_price item.product.price
		json.total_price item.price
		end
	end
end