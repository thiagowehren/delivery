#!/bin/bash

# Nome da rede Docker
NETWORK_NAME="my_network"

# Criar a rede Docker se ela não existir
if ! docker network ls | grep -q $NETWORK_NAME; then
  docker network create $NETWORK_NAME
fi

# Remover o conteiner do Elasticsearch se estiver rodando
docker rm -f elasticsearch 2>/dev/null

# Remover o conteiner do Delivery se estiver rodando
docker rm -f delivery 2>/dev/null

# Remover temporários (se necessário)
sudo rm -rf tmp

# Executar o Elasticsearch
echo "Iniciando Elasticsearch..."
docker run -d --name elasticsearch \
  -p 127.0.0.1:9200:9200 \
  -p 127.0.0.1:9300:9300 \
  -e "discovery.type=single-node" \
  --network $NETWORK_NAME \
  docker.elastic.co/elasticsearch/elasticsearch:7.17.8

# Capturar o IP do contêiner Elasticsearch
ES_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' elasticsearch)

echo "Construindo a imagem"
# Construir a imagem 'delivery' usando o Dockerfile dev.dockerfile
docker build -f dev.dockerfile -t delivery .

# Esperar o Elasticsearch estar disponível
echo "Esperando o Elasticsearch iniciar..."
until curl -s "http://${ES_IP}:9200/_cluster/health?wait_for_status=yellow&timeout=60s" | grep -q '"status":"yellow"\|"status":"green"'; do
  echo "Elasticsearch não está disponível ainda - esperando"
  sleep 5
done
echo "Elasticsearch está disponível!"

echo "Iniciando dev.dockerfile..."
# Executar o contêiner 'delivery'
docker run -d --name delivery --network $NETWORK_NAME -p 8000:8000 -v $(pwd):/rails delivery

# Adicionar o hostname 'elasticsearch' no arquivo /etc/hosts do contêiner 'delivery'
docker exec delivery bash -c "echo '${ES_IP} elasticsearch' >> /etc/hosts"

echo "Configuração concluída!"
