json.extract! product, :id, :title
json.price product.price
json.url "#{request.original_url}#{product.id}.json"
