#!/usr/bin/env bash
# docker image of apache server saying hello world
port=$1
domain=$2
docker pull ubuntu/apache2

containerName=$(docker ps -a | grep -w bob) 
if [[ "$containerName" != "" ]] ; then 
    docker rm -f bob
fi

docker run -p "$port":80 --name bob -v ~/apache2Test:/var/www/html ubuntu/apache2
docker exec -ti bob sh -c mkdir -p /var/www/"$domain" && cp /var/www/html/"$domain".conf /etc/apache2/sites-available/ && a2ensite "$domain".conf && systemctl reload apache2 # toreplace by docker file
#docker exec -ti bob bash

#docker stop bob
#docker rm bob
#docker rm -f bob