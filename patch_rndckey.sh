#!/bin/bash 

CONTAINER_ID=$(sudo podman ps | grep designate_mdns | awk '{print $1}')
sudo podman exec -it ${CONTAINER_ID} cat  /etc/rndc.key | sudo tee /etc/rndc.key 
sudo systemctl restart named 
sudo systemctl status named