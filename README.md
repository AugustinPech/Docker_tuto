## knowledge at day 0

I made a docker image once, 2 months ago.

# Mono service : deployment of an apache2 server
If you allready have de VM, run the script with the command :
```bash 
bash ./scripts/testOnVM.sh userName VMName domainName
```
## docker installation

I made a [script](scripts/installDocker.sh) to automaticaly install docker. I tested it on Ubuntu22.04 and Debian12, works so far.

## apache2 container

I made a [script](scripts/firstContainer.sh) to automaticaly create an apache2 container with dynamicaly generated [file.conf](apache2Test/conf/patate.conf).

## deployment on a "remote server"

I made a [script](scripts/testOnVM.sh) to transfer and run the scripts on a "remote server" (being a KVM vmirtual machine I generated with a [script](https://github.com/AugustinPech/KVM_auto-deploy/blob/main/scripts/createAndConfigVM.sh)).

# Multi-containers & Mutli-service
