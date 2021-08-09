#!/bin/bash 
RESULT=$(sudo vgdisplay | grep "VG Name" | grep ceph | awk '{print $3}')
if [[ ! -z ${RESULT} ]];
then 
  sudo vgremove $(sudo vgdisplay | grep "VG Name" | grep ceph | awk '{print $3}')
fi