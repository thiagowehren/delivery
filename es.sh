#!/bin/bash

# Remove o contêiner Elasticsearch anterior, se existir
docker rm -f elasticsearch 2>/dev/null

echo "Iniciando Elasticsearch..."
# Inicia o contêiner Elasticsearch com limitação de recursos
docker run -d --name elasticsearch \
  -p 127.0.0.1:9200:9200 \
  -p 127.0.0.1:9300:9300 \
  --memory=512m --cpus=1 \
  -e "discovery.type=single-node" \
  docker.elastic.co/elasticsearch/elasticsearch:7.17.8

echo "Esperando o Elasticsearch iniciar..."

# Loop até que o Elasticsearch esteja disponível
until curl -s "http://127.0.0.1:9200/_cluster/health?wait_for_status=yellow&timeout=60s" | grep -q '"status":"yellow"\|"status":"green"'; do
  echo "Elasticsearch não está disponível ainda - esperando"
  sleep 5
done
echo "Elasticsearch está disponível!"

# Após o Elasticsearch estar disponível, execute os comandos de reindexação no Rails
echo "Executando reindexação no Rails..."

# Reindexa o modelo Store
rails runner -e development "Store.reindex"

# Reindexa o modelo Product
rails runner -e development "Product.reindex"

# Início do servidor Rails
rails s -p 8000