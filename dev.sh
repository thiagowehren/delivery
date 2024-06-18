# Remover o conteiner do Elasticsearch se estiver rodando
docker rm -f elasticsearch 2>/dev/null

# Remover temporários (se necessário)
sudo rm -rf tmp

# Executar o Elasticsearch
echo "Iniciando Elasticsearch..."
docker run -d --name elasticsearch \
  -p 127.0.0.1:9200:9200 \
  -p 127.0.0.1:9300:9300 \
  -e "discovery.type=single-node" \
  docker.elastic.co/elasticsearch/elasticsearch:7.17.8


echo "Construindo a imagem"
# Construir a imagem 'delivery' usando o Dockerfile dev.dockerfile
docker build -f dev.dockerfile -t delivery .

echo "Iniciando dev.dockerfile..."
# Executar o conteiner 'delivery'
docker run -p 8000:8000 -v $(pwd):/rails delivery