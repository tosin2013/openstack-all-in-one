# Below are helpful command and notes for OpenStack All-in-One Deployment

**Install OpenShift**  
[Configure OpenShift](configure-openshift.md)

**Get credentials**
```
./openstack-all-in-one/openstack-commands/get-credentials.sh
```

**List endpoints**
```
./openstack-all-in-one/openstack-commands/list-endpoints.sh
```

**Create Projects**
```
export OS_CLOUD=standalone
openstack project create --description 'OpenShift' openshift --domain default
```

**Configure DNS Zone if using designate**
```
./openstack-all-in-one/openstack-commands/configure_dns_zone.sh example.com
```

**Create RecordSets in this DNS Zone**
```
openstack recordset create --records '10.0.0.1' --type A example.com. www
```

**Add user to project**
```
openstack user create --project openshift --password Ch4nG3m$ admin
```


**Variables for public and private network**
```
export SECOND_IP=$(echo `ifconfig br-ctlplane |awk '/inet/ {print $2}'| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`)
export IP_OCTET=$(echo ${SECOND_IP} | cut -d"." -f1-3)
echo ${IP_OCTET} 

export GATEWAY=${IP_OCTET}.1
export PUBLIC_NETWORK_CIDR=${IP_OCTET}.0/24
export PRIVATE_NETWORK_CIDR=192.168.100.0/24
export PUBLIC_NET_START=${IP_OCTET}.3
export PUBLIC_NET_END=${IP_OCTET}.254
export DNS_SERVER=10.0.1.239
```

**Create public netowork**
```
openstack network create --external --provider-physical-network datacentre --provider-network-type flat public
openstack subnet create public-net \
    --subnet-range $PUBLIC_NETWORK_CIDR \
    --no-dhcp \
    --gateway $GATEWAY \
    --allocation-pool start=$PUBLIC_NET_START,end=$PUBLIC_NET_END \
    --network public
```
**Create private network**
```
openstack network create --internal private
openstack subnet create private-net \
    --subnet-range $PRIVATE_NETWORK_CIDR \
    --network private
openstack router add subnet vrouter private-net
```

**Create router and set gateway**
```
openstack router create vrouter
openstack router set vrouter --external-gateway public
```

**Generate floating ip**
```
openstack floating ip create public
```
