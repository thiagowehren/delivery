json.products @store.products do |product|
  json.partial! "products/product", locals: { product: product}
end