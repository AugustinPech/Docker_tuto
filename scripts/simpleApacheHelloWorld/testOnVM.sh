#!/usr/bin/env bash

userName=$1
VMName=$2
domain=$3

function sed_files {
  VMName_bp="<VMNAME>"
  domain_bp="<DOMAIN>"
  userName_bp="<USERNAME>"
  cp /home/augustin/Desktop/docker/apache2Test/conf/vhost.conf /home/augustin/Desktop/docker/apache2Test/conf/"$domain".conf
  sed -i "s/$userName_bp/$userName/g" /home/augustin/Desktop/docker/apache2Test/conf/"$domain".conf
  sed -i "s/$domain_bp/$domain/g" /home/augustin/Desktop/docker/apache2Test/conf/"$domain".conf
  sed -i "s/$VMName_bp/$VMName/g" /home/augustin/Desktop/docker/apache2Test/conf/"$domain".conf
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
    sleep 5
  done
  # SSHPASS="$password" sshpass -e ssh-copy-id -o StrictHostKeyChecking=no -i /home/augustin/.ssh/id_ed25519.pub "$userName"@"$ipVM"
}
function sendScripts {
  ssh -o StrictHostKeyChecking=no "$userName"@"$ipVM" 'rm -rf ~/installDocker.sh'
  ssh -o StrictHostKeyChecking=no "$userName"@"$ipVM" 'rm -rf ~/firstContainer.sh'
  scp -o StrictHostKeyChecking=no /home/augustin/Desktop/docker/scripts/simpleApacheHelloWorld/installDocker.sh  "$userName"@"$ipVM":~/
  scp -o StrictHostKeyChecking=no /home/augustin/Desktop/docker/scripts/simpleApacheHelloWorld/firstContainer.sh "$userName"@"$ipVM":~/
}
function runScripts {
  port=$1
  ssh -o StrictHostKeyChecking=no "$userName"@"$ipVM" 'bash ~/installDocker.sh'
  ssh -o StrictHostKeyChecking=no "$userName"@"$ipVM" 'bash ~/firstContainer.sh' "$port" "$domain"
}
function sendFiles {
  ssh -o StrictHostKeyChecking=no "$userName"@"$ipVM" 'rm -rf ~/apache2Test'
  scp -r -o StrictHostKeyChecking=no /home/augustin/Desktop/docker/apache2Test/ "$userName"@"$ipVM":~/apache2Test/
}
SSHConnectReady &&
sed_files &&
sendScripts &&
sendFiles &&
runScripts 8080

# google-chrome http://"$ipVM":"$port"
google-chrome http://"$domain".docker:"$port"
