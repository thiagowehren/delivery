json.id order.id
json.store_id order.store_id
json.state order.state
json.created_at order.created_at.in_time_zone("Brasilia").strftime("%H:%M %d/%m/%Y")
json.updated_at order.updated_at.in_time_zone("Brasilia").strftime("%H:%M %d/%m/%Y")
json.total_price number_to_currency(order.total_price)
json.possible_states order.state_transitions.map(&:event)
