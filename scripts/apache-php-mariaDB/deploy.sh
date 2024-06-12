#!/usr/bin/env bash

userName=$1
VMName=$2
domain=$3
port=$4
containerName="bob"

function sed_files {
  echo "seding files"
  VMName_bp="<VMNAME>"
  domain_bp="<DOMAIN>"
  userName_bp="<USERNAME>"
  cp /home/augustin/Desktop/docker/mySite/conf/vhost.conf /home/augustin/Desktop/docker/mySite/conf/"$domain".conf
  sed -i "s/$userName_bp/$userName/g" /home/augustin/Desktop/docker/mySite/conf/"$domain".conf
  sed -i "s/$domain_bp/$domain/g" /home/augustin/Desktop/docker/mySite/conf/"$domain".conf
  sed -i "s/$VMName_bp/$VMName/g" /home/augustin/Desktop/docker/mySite/conf/"$domain".conf
  sudo sed -i "/\.docker/c\\$ipVM $domain.docker" /etc/hosts
}
function ipVM {
  macVM=$(virsh dumpxml "$VMName" | grep "mac address" | awk -F\' '{print $2}')
  ipVM=$(arp -an | grep "$macVM" | awk -F'(' '{print $2}' | awk -F')' '{print $1}')
  echo "VM's IP = " "$ipVM"
}
function SSHConnectReady {
  ipVM 
  echo "Trying to connect to $userName@$ipVM"
  while !  nc -z "$ipVM" 22 ; do
    echo "Waiting for the VM to be ready..."
    ipVM
    sleep 2
  done
}
function sendScripts {
  echo "sending scripts"
  scp -o StrictHostKeyChecking=no -r /home/augustin/Desktop/docker/scripts/apache-php-mariaDB/ "$userName"@"$ipVM":~/apache-php-mariaDB/
}
function runScriptsOnVM {
  echo "running scripts"
  ssh -o StrictHostKeyChecking=no "$userName"@"$ipVM" 'bash -s' < /home/augustin/Desktop/docker/scripts/apache-php-mariaDB/installDocker.sh
  ssh -o StrictHostKeyChecking=no "$userName"@"$ipVM" 'bash -s' < /home/augustin/Desktop/docker/scripts/apache-php-mariaDB/network.sh
  ssh -o StrictHostKeyChecking=no "$userName"@"$ipVM" 'bash -s' < /home/augustin/Desktop/docker/scripts/apache-php-mariaDB/apacheContainer.sh "$userName" "$port" "$domain" "$containerName"
}
function sendFiles {
  echo "sending files"
  scp -o StrictHostKeyChecking=no -r /home/augustin/Desktop/docker/mySite/ "$userName"@"$ipVM":/home/"$userName"/
}
SSHConnectReady &&
sed_files &&
sendScripts &&
sendFiles &&
runScriptsOnVM