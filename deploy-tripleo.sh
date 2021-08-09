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
if [[ ! -z ${RESULT} ]];
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

if [ $USE_DESIGNATE  == "true"  ];
then 
  sudo openstack tripleo deploy \
  --templates \
  --local-ip=$IP/$NETMASK \
  -e /usr/share/openstack-tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/enable-designate.yaml \
  -e ${HOME}/designate-config.yaml \
  -r /usr/share/openstack-tripleo-heat-templates/roles/Standalone.yaml \
  -e $HOME/containers-prepare-parameters.yaml \
  -e $HOME/standalone_parameters.yaml \
  -e $HOME/ceph_parameters.yaml \
  --output-dir $HOME \
  --standalone

  echo "Patch rndc key"
  CONTAINER_ID=$(sudo podman ps | grep designate_mdns | awk '{print $1}')
  sudo podman exec -it ${CONTAINER_ID} cat  /etc/rndc.key | sudo tee /etc/rndc.key 
  sudo systemctl restart named 
  sudo systemctl status named
else 
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
fi 



