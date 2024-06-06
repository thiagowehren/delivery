json.extract! store, :id, :name, :created_at, :updated_at
json.url store_url(store, format: :json)
json.image_url "#{request.protocol}#{request.host_with_port}#{url_for(store.image_with_default)}"
