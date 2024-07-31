#!/bin/bash

build_container(){
  docker build -t ikev2 .
}

run_docker(){
    sudo docker run --restart=always -itd --privileged -v /lib/modules:/lib/modules \
-e HOST_IP=$PUBLIC_IP -e VPNUSER=$VPNUSER -e VPNPASS="$VPNPASS" \
-p 500:500/udp -p 4500:4500/udp --name=ikev2-vpn ikev2
}

run_vpnserver(){
  export PUBLIC_IP=`dig +short myip.opendns.com @resolver1.opendns.com`
  export VPNUSER=$1
  export VPNPASS=$2
  CONTAINER_NAME=`sudo docker ps -f name=ikev2-vpn --format '{{.Names}}'`

  echo -e "\n*************** Start vpn server...***************"

  if [ "$CONTAINER_NAME" = 'ikev2-vpn' ]; then
    echo -e "\n*************** Delete old vpn server. "
    sudo docker rm -f $CONTAINER_NAME
    run_docker
  else
    run_docker
  fi

  echo -e "\n*************** Vpn Server is up, just a moment... ***************"
  sleep 3
}

generate_cert(){
  echo -e "\n*************** Generate certificate ***************"
  sudo docker exec -it ikev2-vpn sh /usr/bin/vpn
  echo -e "\n*************** Congratulations. 42. *************** "
  echo "Note: Don't forget to set the cloud host's firewall to allow udp port 500 and port 4500 traffic ! ^_^"
}


build_container
run_vpnserver $@
generate_cert
