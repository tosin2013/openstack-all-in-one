#!/bin/bash 
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

echo "Tearing down OpenStack environment"
if type pcs &> /dev/null; then
    sudo pcs cluster destroy
fi
if type podman &> /dev/null; then
    echo "Removing podman containers and images (takes times...)"
    COUNT=$(podman ps -a | wc -l)
    while [ ${COUNT} -gt 1 ]
    do
        sudo podman rm -af
        sudo podman rmi -af
        echo "Trying Again in  5 minutes"
        sleep 360s
        COUNT=$(podman ps -a | wc -l)
    done
fi

function check_overlay_mount_points(){
  ps -ef | grep -v auto | grep /var/lib/containers/storage/ >/tmp/command_status
  if  grep -q "overlay-containers" /tmp/command_status;
  then 
    OVERLAYPROCESS=$(${SUDO} ps -ef | grep -v auto | grep /var/lib/containers/storage/ | awk '{print $2}')
    ps -ef | grep -v auto | grep /var/lib/containers/storage/ >/tmp/command_status
    if  grep -q "overlay-containers" /tmp/command_status;
    then 
      for OVERLAYPS in $OVERLAYPROCESS
      do
        ${SUDO} kill -15 $OVERLAYPS
      done
    fi 
    remove_all_overlay_mount_points
  fi 
  rm /tmp/command_status
}

function remove_all_overlay_mount_points(){
  if [[ ! -z $(${SUDO} mount | grep overlay ) ]];
  then 
    ${SUDO} mount | grep overlay | awk '{print $3}' | xargs ${SUDO} umount
  fi 
}


sudo rm -rf \
    /var/lib/tripleo-config \
    /var/lib/config-data /var/lib/container-config-scripts \
    /var/lib/container-puppet \
    /var/lib/heat-config \
    /var/lib/image-serve \
    /var/lib/containers \
    /etc/systemd/system/tripleo* \
    /var/lib/mysql/*
sudo systemctl daemon-reload
check_overlay_mount_points