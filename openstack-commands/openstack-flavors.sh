export OS_CLOUD=standalone
openstack flavor list

openstack flavor create --public openshift.image --id auto --ram 16384 --disk 120 --vcpus 4
openstack flavor list