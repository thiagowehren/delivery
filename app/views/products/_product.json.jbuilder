json.extract! product, :id, :title, :price
json.url "#{request.original_url}#{product.id}.json"
