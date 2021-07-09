#!/bin/bash
set -xe 
CHECKLOGGINGUSER=$(whoami)
if [ ${CHECKLOGGINGUSER} != "stack" ];
then 
  echo "login as stack user to run script."
  echo "You are currently logged in as $USER"
  exit 1
fi

echo "Check that ceph volume is removed from hard drives"
RESULT=$(sudo vgdisplay | grep "VG Name" | grep ceph | awk '{print $3}')
if [ ! -z ${RESULT} ];
then 
  sudo vgremove $(sudo vgdisplay | grep "VG Name" | grep ceph | awk '{print $3}')
fi

if [ -f $HOME/openstack-info ];
then 
  source  $HOME/openstack-info
  sudo podman login registry.redhat.io --username ${RHEL_USER} --password ${RHEL_PASSWORD}
else
  sudo podman login registry.redhat.io
fi


source  "$HOME/network_info"
 
sudo  touch /etc/environment
sudo openstack tripleo deploy \
--templates \
--local-ip=$IP/$NETMASK \
-e /usr/share/openstack-tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
-r /usr/share/openstack-tripleo-heat-templates/roles/Standalone.yaml \
-e $HOME/containers-prepare-parameters.yaml \
-e $HOME/standalone_parameters.yaml \
-e $HOME/ceph_parameters.yaml \
--output-dir $HOME \
--standalone
