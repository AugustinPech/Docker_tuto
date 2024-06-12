#!/usr/bin/env bash

userName=$1
port=$2
containerName=$4
domain=$3
docker pull mariadb
docker pull ubuntu/apache2
docker pull php:8.2-fpm

containerRunning=$(docker ps -a | grep -w "$containerName") 
if [[ "$containerRunning" != "" ]] ; then 
    docker rm -f "$containerName"
fi
containerRunning=$(docker ps -a | grep -w mariadb) 
if [[ "$containerRunning" != "" ]] ; then 
    docker rm -f mariadb
fi
containerRunning=$(docker ps -a | grep -w php) 
if [[ "$containerRunning" != "" ]] ; then 
    docker rm -f php
fi

echo 1
docker run --security-opt apparmor=unconfined -d --name mariadb \
    --network myNet \
    --network-alias mariadb \
    -v /home/augustin/Desktop/docker/mySite/mariadb:/home/"$userName"/mySite/mariadb \
    -e MYSQL_ROOT_PASSWORD=root \
    -e MYSQL_DATABASE=personas \
    mariadb
echo 2
docker exec mariadb sh -c "mariadb -uroot -proot personas < /home/$userName/mySite/mariadb/personas.sql"
echo 3
docker run --security-opt apparmor=unconfined -d \
    -p 9000:9000 \
    --name php \
    --network myNet \
    --network-alias php \
    php:8.2-fpm
echo 4
docker run -d --security-opt apparmor=unconfined \
    -p "$port":80 \
    --name "$containerName" \
    --network myNet \
    -v /home/"$userName"/mySite:/var/www/html \
    -e MYSQL_HOST=mariadb \
    -e MYSQL_USER=root \
    -e MYSQL_PASSWORD=root \
    -e MYSQL_DATABASE=personas \
    -e PHP_ENABLE_MYSQLND=yes \
    -e PHP_MYSQL_HOST=mariadb \
    -e PHP_MYSQL_USER=root \
    -e PHP_MYSQL_PASSWORD=root \
    -e PHP_MYSQL_DATABASE=personas \
    ubuntu/apache2
echo 5
docker exec "$containerName" sh -c "mkdir -p /var/www/$domain && cp /var/www/html/conf/$domain.conf /etc/apache2/sites-available/ && a2ensite $domain.conf && a2dismod mpm_prefork && a2enmod proxy_fcgi setenvif mpm_event && a2enconf php8.2-fpm"
# echo 6
# docker exec "$containerName" sh -c "chown -R www-data:www-data /var/www/html"
# echo 7
# docker exec "$containerName" sh -c "usermod -aG www-data $USER"
echo 8
docker exec "$containerName" sh -c "service apache2 reload"
echo 9