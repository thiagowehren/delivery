json.pagination do
    current = @stores.current_page
    total = @stores.total_pages
    per_page = @stores.limit_value

    json.current current
    json.per_page per_page
    json.pages total
    json.count @stores.total_count
    json.previous (current > 1 ? (current -1) : nil)
    json.next (current == total ? nil: (current +1))
end

json.stores do
    json.array! @stores, partial: "stores/store", as: :store
end