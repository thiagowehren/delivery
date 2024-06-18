json.search do
  json.products @products do |product|
    json.partial! "products/product", product: product
  end

  json.stores do
    json.array! @stores, partial: "stores/store", as: :store
  end
end