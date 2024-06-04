class MarkAsExpiredJob < ApplicationJob
  include ActionView::RecordIdentifier
  
  queue_as :default

  def perform(product_id)
    product = Product.find(product_id)
    product.update(expired: true)

    #Turbo broadcast
    Turbo::StreamsChannel.broadcast_remove_to("products", target: dom_id(product))
  end
end
