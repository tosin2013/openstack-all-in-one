#!/bin/bash
if [ -f $HOME/openstack-info ];
then 
    source  $HOME/openstack-info
else
    read -p "Enter primary DNS > " PRIMARY_DNS_SERVER
fi

export OS_CLOUD=standalone

export SECOND_IP=$(echo `ifconfig br-ctlplane |awk '/inet/ {print $2}'| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`)
export IP_OCTET=$(echo ${SECOND_IP} | cut -d"." -f1-3)
echo ${IP_OCTET} 

export GATEWAY=${IP_OCTET}.1
export PUBLIC_NETWORK_CIDR=${IP_OCTET}.0/24
export PUBLIC_NET_START=${IP_OCTET}.3
export PUBLIC_NET_END=${IP_OCTET}.254
export DNS_SERVER=${PRIMARY_DNS_SERVER}

openstack network create --external --provider-physical-network datacentre --provider-network-type flat public
openstack subnet create public-net \
    --subnet-range $PUBLIC_NETWORK_CIDR \
    --no-dhcp \
    --gateway $GATEWAY \
    --allocation-pool start=$PUBLIC_NET_START,end=$PUBLIC_NET_END \
    --network public

openstack router create vrouter
openstack router set vrouter --external-gateway public
