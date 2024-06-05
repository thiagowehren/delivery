docker build -f dev.dockerfile -t delivery . && 
docker run -p 8000:8000 -v $(pwd):/rails delivery