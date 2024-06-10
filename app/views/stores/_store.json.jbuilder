json.id store.id
json.name store.name
json.created_at store.created_at.in_time_zone("Brasilia").strftime("%H:%M %d/%m/%Y")
json.updated_at store.updated_at.in_time_zone("Brasilia").strftime("%H:%M %d/%m/%Y")
json.url store_url(store, format: :json)

if current_user.seller?
    json.hidden store.hidden
end

if !store.image_with_default.nil?
    json.image_url "#{request.protocol}#{request.host_with_port}#{url_for(store.image_with_default)}"
else
    json.image_url nil
end