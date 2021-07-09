#!/bin/bash

echo "Configure packages for OpenStack Deployment"

if [ ! -f /usr/bin/curl ];
then
  echo "Curl is not installed script is unable to run."
  exit 1
fi

echo "Downloading Scripts"
curl -L https://raw.githubusercontent.com/tosin2013/openstack-all-in-one/main/register-system.sh --output /tmp/register-system.sh
curl -L https://raw.githubusercontent.com/tosin2013/openstack-all-in-one/main/configure-openstack-subs.sh  --output /tmp/configure-openstack-subs.sh 
curl -L https://raw.githubusercontent.com/tosin2013/openstack-all-in-one/main/configure-tmux.sh  --output /tmp/configure-tmux.sh

chmod +x /tmp/register-system.sh
chmod +x /tmp/configure-openstack-subs.sh
chmod +x /tmp/configure-tmux.sh

/tmp/register-system.sh
/tmp/configure-openstack-subs.sh
/tmp/configure-tmux.sh