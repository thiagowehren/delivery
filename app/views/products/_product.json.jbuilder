json.extract! product, :id, :title
json.price product.price
if !product.image_with_default.nil?
    json.image_url "#{request.protocol}#{request.host_with_port}#{url_for(product.image_with_default)}"
else
    json.image_url nil

end