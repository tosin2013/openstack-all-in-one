#!/bin/bash 
set -xe 

function drivecheck(){
  CHECK_DRIVE_COUNT=$(ls /dev/*sd* | grep -v sda | wc -l)
  if [ "$CHECK_DRIVE_COUNT" -gt 1 ];
  then 
    echo "more than one drive found"
    export DRIVES=$(ls /dev/sd* | grep -v sda |  xargs)
  elif [ "$CHECK_DRIVE_COUNT" -eq 0 ];
  then 
      echo "checking for nvme drives"
      export DRIVES="$(ls /dev/nvme0* | grep /dev/nvme0n1)"
  elif [ "$CHECK_DRIVE_COUNT" -eq 1 ];
  then
       echo "one drive found"
       export DRIVES="$(ls /dev/sd* | grep -v sda)"
  fi 
}

function checkfstab(){
  CHECK_SUDO_STACK="/etc/fstab"
  if sudo grep -q  '/var/lib/ceph-storage' "$CHECK_SUDO_STACK"; then
    echo "/var/lib/ceph-storage exisits in /etc/fstab"
  else
    sudo echo "/dev/vg_ceph_storage/data-lv2   /var/lib/ceph-storage  ext4   defaults    0   0" | sudo tee -a /etc/fstab
  fi
}


drivecheck
sudo pvcreate ${DRIVES}
sudo vgcreate vg_ceph_storage ${DRIVES}
export VG_SIZE="$(sudo vgdisplay vg_ceph_storage | grep  'VG Size' | grep -oE  '[0-9]{3}.[0-9]{2} [G,T]iB')" #1.7T
GB='GiB'
TB='TiB'
REDUCE_DRIVE="10"

case $VG_SIZE in

  *"$GB"*)
    NEWSIZE=$(echo $VG_SIZE | grep -oE [0-9]{3})
    REDUCE="$(($NEWSIZE-$REDUCE_DRIVE))"
    echo $REDUCE
    export SIZE=$( echo "${REDUCE}"G)
    echo "SIZE: ${SIZE}"
    ;;
  *"$TB"*)
    NEWSIZE=$(echo $VG_SIZE | grep -oE [0-9]{3})
    export SIZE=$( echo "${NEWSIZE}"T)
    echo "SIZE: ${SIZE}"
    ;;
esac

sudo lvcreate -L${SIZE} -n data-lv2 vg_ceph_storage -y
sudo mkfs.ext4 /dev/vg_ceph_storage/data-lv2
sudo mkdir -p /var/lib/ceph-storage/
sudo mount  /dev/vg_ceph_storage/data-lv2 /var/lib/ceph-storage
checkfstab




