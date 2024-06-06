json.extract! product, :id, :title
json.price product.price
json.image_url "#{request.protocol}#{request.host_with_port}#{url_for(product.image_with_default)}"
