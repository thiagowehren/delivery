json.extract! order, :id, :state, :created_at
json.total_price number_to_currency(order.total_price)
