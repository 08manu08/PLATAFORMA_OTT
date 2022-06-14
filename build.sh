#!/bin/bash
# USER="manudocker08"
# PASS="D0ck3r08;"
REPO=manudocker08
echo "introduce los siguiente parametros con comillas dobles"
read -p "introducce username: " $1
read -p "introduce password: " $2
docker login --username=$1 --password=$2
echo "built docker images and proceeding to delete existing container"
result=$( docker ps -q -f name=server )
if [[ $? -eq 0 ]]; then
    echo "Container exists"
    docker container rm -f server
    echo "Deleted the existing docker container"
else
    echo "No such container"
fi
docker build . -t $REPO/server-hls:latest > output
echo "imagen contruida exitosamente"
docker push $REPO/server-hls:latest
echo "imagen subida exitosamente"
docker pull $REPO/server-hls:latest
echo "Deploying the updated container"
docker-compose up -d
echo "Deploying the container"
