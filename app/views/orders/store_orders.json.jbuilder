json.orders @orders do |order|
  json.id order.id
  json.status order.state
  json.created_at order.created_at.in_time_zone("Brasilia").strftime("%H:%M %d/%m/%Y")
  json.price order.total_price
end