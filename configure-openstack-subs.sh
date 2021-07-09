#!/bin/bash 
set -xe

sudo subscription-manager repos --disable=*
sudo subscription-manager repos \
--enable=rhel-8-for-x86_64-baseos-rpms \
--enable=rhel-8-for-x86_64-appstream-rpms \
--enable=rhel-8-for-x86_64-highavailability-rpms \
--enable=ansible-2.9-for-rhel-8-x86_64-rpms \
--enable=openstack-16.1-for-rhel-8-x86_64-rpms \
--enable=fast-datapath-for-rhel-8-x86_64-rpms \
--enable=advanced-virt-for-rhel-8-x86_64-rpms || exit $?

sudo dnf module disable -y container-tools:rhel8
sudo dnf module enable -y container-tools:2.0""
sudo dnf module disable -y virt:rhel
sudo dnf module enable -y virt:8.2

sudo yum install -y python3-tripleoclient
sudo dnf install -y bind-utils vim git ncurses-devel curl wget tmux net-tools
sudo dnf update -y 

if [ ! -d /usr/share/ceph-ansible ];
then 
  sudo subscription-manager repos --enable=rhceph-4-tools-for-rhel-8-x86_64-rpms 
  sudo dnf install -y ceph-ansible util-linux lvm2
fi 