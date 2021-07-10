#!/bin/bash 
#set -xe 
if [ -f $HOME/openstack-info ];
then 
    source  $HOME/openstack-info
else
    read -p "Enter secondary network etherface name to be used for OpenStack > " SECONDARY_INTERFACE_NAME
    read -p "Enter time server > " TIME_SERVER
    read -p "Enter primary DNS > " PRIMARY_DNS_SERVER
    read -p "Enter secondary DNS > " SECONDARY_DNS_SERVER
fi

nextip(){
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 1 ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$NEXT_IP"
}

echo "Collecting IP for  $SECONDARY_INTERFACE_NAME"
export CURRENT_IP=$(echo `ifconfig $SECONDARY_INTERFACE_NAME |awk '/inet/ {print $2}'| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`)
export IP_OCTET=$(echo ${CURRENT_IP} | cut -d"." -f1-3)

if [ -z ${CURRENT_IP} ];
then 
  echo "Plese ensure Interface: $SECONDARY_INTERFACE_NAME is configured and active"
  exit 1
fi 

if ping -c 1 ${CURRENT_IP} > /dev/null; 
then
  echo "ping success"
else 
  exit 1
fi

cat <<EOF > $HOME/network_info
export IP=${CURRENT_IP}
export NETMASK=24
export GATEWAY=${IP_OCTET}.1
export INTERFACE=${SECONDARY_INTERFACE_NAME}
export DNS_SERVER1=${PRIMARY_DNS_SERVER}
export DNS_SERVER2=${SECONDARY_DNS_SERVER}
export NTP_SERVER1=${TIME_SERVER}
export IP_OCTET=${IP_OCTET}
EOF


cat $HOME/network_info
source $HOME/network_info

# Need to test vip in tripleo it currently has issues

#echo "testing vip"
#if ping -c 1 ${VIP} > /dev/null; 
#then
#  echo "ping success"
#  echo "Manually configure vip current VIP does not exist"
#  exit 1
#else 
#  echo "VIP does not exist contiuning installation"
#fi
