#!/bin/bash 
set -xe

sudo dnf install -y dnf-utils
sudo subscription-manager repos --disable=*
sudo subscription-manager repos \
--enable=rhel-8-for-x86_64-baseos-eus-rpms \
--enable=rhel-8-for-x86_64-appstream-eus-rpms \
--enable=rhel-8-for-x86_64-highavailability-eus-rpms \
--enable=ansible-2.9-for-rhel-8-x86_64-rpms \
--enable=openstack-16.2-for-rhel-8-x86_64-rpms \
--enable=fast-datapath-for-rhel-8-x86_64-rpms || exit $?

sudo dnf module disable -y container-tools:rhel8
sudo dnf module enable -y container-tools:3.0
sudo dnf module enable -y virt:rhel
sudo dnf update -y 

sudo yum install -y python3-tripleoclient
sudo dnf install -y bind-utils vim git ncurses-devel curl wget tmux net-tools


if [ ! -d /usr/share/ceph-ansible ];
then 
  sudo subscription-manager repos --enable=rhceph-4-tools-for-rhel-8-x86_64-rpms 
  sudo dnf install -y ceph-ansible util-linux lvm2
fi 