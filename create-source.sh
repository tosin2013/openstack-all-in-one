#!/bin/bash 
#set -xe 
if [ -z ${1} ];
then 
  echo "Pass second interface"
  echo "USAGE: $0 eno2"
  exit 1
fi

nextip(){
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 1 ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$NEXT_IP"
}


export SECOND_IP=$(echo `ifconfig $1 |awk '/inet/ {print $2}'| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`)
export IP_OCTET=$(echo ${SECOND_IP} | cut -d"." -f1-3)
export INTERFACE_NAME=${1}
export CURRENT_IP=$(echo `ifconfig $INTERFACE_NAME |awk '/inet/ {print $2}'| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`)
if ping -c 1 ${CURRENT_IP} > /dev/null; 
then
  echo "ping success"
else 
  exit 1
fi

cat <<EOF > $HOME/network_info
export IP=${SECOND_IP}
export NETMASK=24
export GATEWAY=${IP_OCTET}.1
export VIP=$(nextip $SECOND_IP)
export INTERFACE=${INTERFACE_NAME}
export DNS_SERVER1=10.0.1.239
export DNS_SERVER2=8.8.8.8
export NTP_SERVER1=time1.google.com
export IP_OCTET=${IP_OCTET}
EOF


cat $HOME/network_info
source $HOME/network_info

echo "testing vip"
if ping -c 1 ${VIP} > /dev/null; 
then
  echo "ping success"
  echo "Manually configure vip current VIP does not exist"
  exit 1
else 
  echo "VIP does not exist contiuning installation"
fi
