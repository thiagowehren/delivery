json.pagination do
  current = @products.current_page
  total = @products.total_pages
  per_page = @products.limit_value

  json.current current
  json.per_page per_page
  json.pages total
  json.count @products.total_count
  json.previous (current > 1 ? (current -1) : nil)
  json.next (current == total ? nil: (current +1))
end

json.products @products do |product|
  json.partial! "products/product", locals: { product: product}
end