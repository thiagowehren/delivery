Rails.logger.info "Loading Elasticsearch initializer..."

Elasticsearch::Model.client = Elasticsearch::Client.new(
  hosts: ['http://elasticsearch:9200'],
  log: true
)
# Elasticsearch::Model.client = Elasticsearch::Client.new(url: 'http://elasticsearch:9200')

# Log the client config
Rails.logger.info "Elasticsearch client configured: #{Elasticsearch::Model.client.transport.transport.hosts}"
