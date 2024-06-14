json.extract! product, :id, :title, :expires_at
json.price number_to_currency(product.price)

if current_user.seller?
  json.hidden product.hidden
end

if !product.image_with_default.nil?
  json.image_url "#{request.protocol}#{request.host_with_port}#{url_for(product.image_with_default)}"
else
  json.image_url nil
end