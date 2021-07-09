#!/bin/bash 
set -xe
useradd stack
passwd stack
usermod -aG wheel stack
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack